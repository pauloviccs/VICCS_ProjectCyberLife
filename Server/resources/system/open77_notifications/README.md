# open77_notifications

Shared WebUI toast service for Open77 resources. It supports local and server-originated
notifications, six screen positions, four semantic types, custom copy/icon/colour, timed progress,
persistent entries, update, dismissal, broadcast, bounded queues and automatic owner cleanup.

Client packages call the `show`, `update`, `dismiss`, `clear`, `list` and enable-state exports.
Server packages call `Open77.notifications.send`, `broadcast`, `update`, `dismiss` and `clear`;
the runtime automatically scopes every notification to its calling resource.

See [`wiki/notifications.md`](../../wiki/notifications.md) for the complete API and examples.
