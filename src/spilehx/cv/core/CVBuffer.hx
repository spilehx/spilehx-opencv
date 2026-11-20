package spilehx.cv.core;

/**
 * Opaque buffer view for native interoperability. Keep the source image or matrix
 * alive while using the buffer; the view does not own its data.
 */
abstract CVBuffer(Dynamic) from Dynamic to Dynamic {}
