defmodule Read.Organizations do
  alias Read.Organizations.Repo

  defdelegate all(), to: Repo
  defdelegate one(id), to: Repo
end
