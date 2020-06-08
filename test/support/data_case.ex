defmodule Support.DataCase do
  use ExUnit.CaseTemplate, async: false
  alias Support.Helpers.Database

  setup_all do
    :ok = Application.start(:vereine)

    on_exit(fn ->
      :ok = Application.stop(:vereine)
    end)

    :ok
  end

  setup do
    :ok = Database.clear_database()
  end
end
