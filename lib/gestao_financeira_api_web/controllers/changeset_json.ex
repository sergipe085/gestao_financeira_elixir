# lib/gestao_financeira_api_web/controllers/changeset_json.ex
defmodule GestaoFinanceiraApiWeb.ChangesetJSON do
  @doc """
  Renders changeset errors.
  """
  def error(%{changeset: changeset}) do
    %{errors: translate_errors(changeset)}
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  defp translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with dngettext
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However, the error messages in your application are typically
    # defined in English and already properly formatted, so we
    # can safely assume that the message is already translated.
    # If you need to translate the error messages, you can use
    # Phoenix.HTML.Tag.content_tag/3 to wrap the message in a
    # translatable content tag.

    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
