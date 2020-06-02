defmodule Read.Applications do
  alias Read.Applications.ApplicationRepo

  defdelegate all(), to: ApplicationRepo
  defdelegate one(id), to: ApplicationRepo
end
