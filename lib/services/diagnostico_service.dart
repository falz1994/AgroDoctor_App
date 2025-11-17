// Conditional export: use IO implementation on mobile/desktop, web-safe stub on web
export 'diagnostico_service_io.dart'
	if (dart.library.html) 'diagnostico_service_web.dart';
