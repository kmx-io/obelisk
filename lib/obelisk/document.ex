defmodule Obelisk.Document do
  import Earmark, only: [as_html: 1]

  def compile(md_file, {template, renderer}) do
    site_yml = File.read!("site.yml")
    site = Obelisk.FrontMatter.parse(site_yml)
    md = File.read!(md_file)
    {frontmatter, md_content} = parts(md)
    fm = Obelisk.FrontMatter.parse(frontmatter)
    {layout_template, layout_renderer} = Obelisk.Layout.layout()

    {:ok, content} = as_html(md_content)

    File.write(
      html_filename(md_file),
      Obelisk.Renderer.render(
        layout_template,
        [
          js: Obelisk.Assets.js(),
          css: Obelisk.Assets.css(),
          content:
            Obelisk.Renderer.render(
              template,
              [content: content, frontmatter: fm, site: site],
              renderer
            ),
          site: site
        ],
        layout_renderer
      )
    )
  end

  def prepare(md_file, {template, renderer}) do
    site_yml = File.read!("site.yml")
    site = Obelisk.FrontMatter.parse(site_yml)
    md = File.read!(md_file)
    {frontmatter, md_content} = parts(md)
    fm = Obelisk.FrontMatter.parse(frontmatter)

    {:ok, content, _res} = as_html(md_content)

    content =
      Obelisk.Renderer.render(
        template,
        [content: content, frontmatter: fm, filename: file_name(md_file), site: site],
        renderer
      )

    assigns = [js: Obelisk.Assets.js(), css: Obelisk.Assets.css(), content: content, site: site]
    {layout_template, layout_renderer} = Obelisk.Layout.layout()
    document = Obelisk.Renderer.render(layout_template, assigns, layout_renderer)

    %{
      frontmatter: fm,
      content: content,
      document: document,
      path: html_filename(md_file),
      filename: file_name(md_file)
    }
  end

  def write_all(pages) do
    Enum.each(pages, fn page ->
      File.write(page.path, page.document)
    end)
  end

  def file_name(md) do
    filepart = String.split("#{md}", "/") |> Enum.reverse() |> hd
    String.replace(filepart, ".markdown", ".html")
  end

  def html_filename(md) do
    "./build/#{file_name(md)}"
  end

  def title(md) do
    String.capitalize(
      String.replace(String.replace(String.slice(md, 11, 1000), "-", " "), ".markdown", "")
    )
  end

  def parts(page_content) do
    [frontmatter | content] = String.split(page_content, "\n---\n")
    {frontmatter, Enum.join(content, "\n")}
  end

  def create(title) do
    File.write(filename_from_title(title), Obelisk.Templates.post(title))
  end

  def filename_from_title(title) do
    datepart = Chronos.today() |> Chronos.Formatter.strftime("%Y-%0m-%0d")
    titlepart = String.downcase(title) |> String.replace(" ", "-")
    "./posts/#{datepart}-#{titlepart}.markdown"
  end
end
