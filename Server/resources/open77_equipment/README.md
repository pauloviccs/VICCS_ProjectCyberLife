# open77_equipment

Client equipment API and replication adapter. Depends on `open77_appearance`, whose
`server/presentation.lua` owns the authenticated, per-character equipment and wardrobe
records and persists them through the database bridge. See `docs/equipment.md`.

The legacy server `Open77.clothing` request/result API is handled by this client.
