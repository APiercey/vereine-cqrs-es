defmodule Read.Applications do
  alias Read.Applications.Repo

  defdelegate all(), to: Repo
  defdelegate one(id), to: Repo
end
