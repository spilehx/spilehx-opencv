package spilehx.cvutils;

import spilehx.cv.ObjDetect;
import spilehx.cv.Core;
import spilehx.cv.core.Mat;
import spilehx.cv.core.Point2D32f;

class MarkerHelper {
	/**
	 * Returns registered DICT_5X5_50 markers with their IDs and four corner coordinates.
	 * Includes markers absent from the current frame until their one-second timeout
	 * expires; expired entries are removed on the next non-null detection call.
	 */
	public static function detectMarkers(source:Mat):Array<Marker> {
		if (source == null) {
			return [];
		}
		var corners:Array<Array<Point2D32f>> = [];
		var ids:Array<Int> = ObjDetect.detectMarkers(source, corners);
		MarkerRegister.instance.beginFrame();

		for (i in 0...ids.length) {
			MarkerRegister.instance.registerMarker(new Marker(ids[i], corners[i]));
		}

		return MarkerRegister.instance.getRegisteredMarkers();
	}

	public static function isUpdated():Bool {
		return MarkerRegister.instance.updated;
	}

	/** Returns rejected square candidates with four corners each and no decoded marker IDs. */
	public static function detectRejectedCandidates(source:Mat):Array<RejectedMarker> {
		if (source == null) {
			return [];
		}
		var rejected:Array<Array<Point2D32f>> = [];
		ObjDetect.detectMarkers(source, [], rejected);
		return [for (corners in rejected) new RejectedMarker(corners)];
	}
}

/** A detected marker with independent corner coordinates in image pixels. */
class Marker {
	@:isVar public var instanceId(default, default):String;
	@:isVar public var id(default, null):Int;
	@:isVar public var lastSeen(default, default):Float;

	/** Clockwise from the marker's top-left corner, accounting for its orientation. */
	@:isVar public var corners(default, null):Array<Point2D32f>;

	@:isVar public var position(default, null):Point2D32f;

	/** Top-edge angle at detection in radians (-PI to PI), positive clockwise in image coordinates. */
	@:isVar public var rotation(default, null):Float;

	public function new(id:Int, corners:Array<Point2D32f>) {
		this.instanceId = uniqueId();
		this.id = id;
		this.lastSeen = Date.now().getTime();
		this.corners = corners;
		this.position = calculatePosition(corners);
		this.rotation = Math.atan2(corners[1].y - corners[0].y, corners[1].x - corners[0].x);
	}

	private function calculatePosition(corners:Array<Point2D32f>):Point2D32f {
		return Core.point2D32f((corners[0].x + corners[1].x + corners[2].x + corners[3].x) / 4,
			(corners[0].y + corners[1].y + corners[2].y + corners[3].y) / 4);
	}

	private function uniqueId():String {
		var chars = "0123456789abcdef";
		var uuid = new StringBuf();

		for (i in 0...36) {
			uuid.add(switch (i) {
				case 8, 13, 18, 23: "-";
				case 14: "4";
				case 19: chars.charAt(8 + Std.random(4));
				default: chars.charAt(Std.random(16));
			});
		}

		return uuid.toString();
	}
}

/** A rejected square candidate with independent corner coordinates in image pixels. */
class RejectedMarker {
	/** Four corners in OpenCV's candidate order, without a canonical marker orientation. */
	@:isVar public var corners(default, null):Array<Point2D32f>;

	public function new(corners:Array<Point2D32f>) {
		this.corners = corners;
	}
}

private class MarkerRegister {
	@:isVar public var updated(default, null):Bool;

	private var registeredMarkers:Map<String, Marker>;
	private var matchedInstances:Map<String, Bool> = new Map<String, Bool>();
	private var initialized:Bool = false;

	private static final DISPOSE_TIMEOUT:Float = 1500; // threshold for disposing old markers in milliseconds
	private static final LOCATION_THRESHOLD:Int = 100; // maximum centre distance in image pixels

	private static final SIGNIFICANT_ROTATION_CHANGE_THRESHOLD:Float = 2 * Math.PI / 180; // 2 degrees in radians
	private static final SIGNIFICANT_LOCATION_CHANGE_THRESHOLD:Float = 2.0; // centre distance in image pixels

	public static final instance:MarkerRegister = new MarkerRegister();

	// private for singleton use only
	private function new() {}

	public function init() {
		if (!initialized) {
			initialized = true;
			updated = false;
			registeredMarkers = new Map<String, Marker>();
			return;
		}
	}

	/** Starts a detection frame; each registered instance can be matched only once. */
	public function beginFrame():Void {
		init();
		updated = false;
		cleanupOldMarkers();
		matchedInstances.clear();
	}

	public function registerMarker(marker:Marker) {
		var existingMarker = isMarkerRegistered(marker);
		if (existingMarker != null) {
			if (isSignificantChange(existingMarker, marker)) {
				updated = true;
			}
			marker.instanceId = existingMarker.instanceId;
			marker.lastSeen = Date.now().getTime();
		} else {
			updated = true;
			trace("Registering new marker with instanceId: " + marker.instanceId);
		}

		registeredMarkers.set(marker.instanceId, marker);
		matchedInstances.set(marker.instanceId, true);
	}

	public function unRegisterMarker(marker:Marker) {
		if (registeredMarkers.exists(marker.instanceId)) {
			trace("Unregistering marker with instanceId: " + marker.instanceId);
			registeredMarkers.remove(marker.instanceId);
			updated = true;
		}
	}

	private function isMarkerRegistered(marker:Marker):Marker {
		var currentMarker:Marker = null;
		var nearestDistanceSquared:Float = LOCATION_THRESHOLD * LOCATION_THRESHOLD;

		for (key in registeredMarkers.keys()) {
			var markerInMap:Marker = registeredMarkers.get(key);
			if (markerInMap.id != marker.id || matchedInstances.exists(key)) {
				continue;
			}
			var dx:Float = markerInMap.position.x - marker.position.x;
			var dy:Float = markerInMap.position.y - marker.position.y;
			var distanceSquared:Float = dx * dx + dy * dy;
			if (distanceSquared <= nearestDistanceSquared) {
				currentMarker = markerInMap;
				nearestDistanceSquared = distanceSquared;
			}
		}

        if (currentMarker == null) {
            trace("No registered marker found for marker with id: " + marker.id);
        }

		return currentMarker;
	}

	private function isSignificantChange(existingMarker:Marker, newMarker:Marker):Bool {
		var dx:Float = newMarker.position.x - existingMarker.position.x;
		var dy:Float = newMarker.position.y - existingMarker.position.y;
		var rotationDifference:Float = Math.abs(newMarker.rotation - existingMarker.rotation);
		rotationDifference = Math.min(rotationDifference, 2 * Math.PI - rotationDifference);

		return dx * dx + dy * dy > SIGNIFICANT_LOCATION_CHANGE_THRESHOLD * SIGNIFICANT_LOCATION_CHANGE_THRESHOLD
			|| rotationDifference > SIGNIFICANT_ROTATION_CHANGE_THRESHOLD;
	}

	public function cleanupOldMarkers() {
		var now = Date.now().getTime();
		for (key in registeredMarkers.keys()) {
			var marker = registeredMarkers.get(key);
			if (now - marker.lastSeen > DISPOSE_TIMEOUT) {
                trace("Disposing marker due to timeout with instanceId: " + marker.instanceId);
				unRegisterMarker(marker);
			}
		}
	}

	public function getRegisteredMarkers():Array<Marker> {
		return [for (marker in registeredMarkers) marker];
	}
}
