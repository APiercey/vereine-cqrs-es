Application.load(:vereine)

for app <- Application.spec(:vereine, :applications) do
  Application.ensure_all_started(app)
end

ExUnit.start()
