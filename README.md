# stack-calibre-web

[Calibre-Web-Automated](https://github.com/crocodilestick/Calibre-Web-Automated),
an ebook library and reader, and its
[book downloader](https://github.com/calibrain/calibre-web-automated-book-downloader),
as a stack for [homelab-ngx](https://github.com/homelab-ngx/homelab-ngx). Both run from their images under podman inside the stack.

## Getting started

1. Add the stack: `homelab stacks add github:homelab-ngx/stack-calibre-web`,
   or Add stack on the dashboard's Stacks page.
2. On the stack's page, press Create on the `BOOKS_DIR` and
   `BOOKS_INGEST_DIR` rows. It makes each folder with the owner the apps
   need.
3. Approve the grants and start the stack.
4. Open `https://calibre.<your domain>`, sign in as `admin` with the
   password `admin123`, change the password and point it at the library.
5. The downloader is at `https://books.<your domain>`.

In step 2 you can type the path of a folder you have instead. It keeps its
owner: the apps write as the owner and group of `BOOKS_DIR`, and the ingest
folder needs write access for that group. Create needs homelab-ngx 0.3.1.

A book dropped in the ingest folder, or fetched by the downloader, is added
to the library.

Send-to-Kindle mails through a relay on the host, port 25. homelab-ngx has no
mail relay on the host yet, so Send-to-Kindle does not work on it today.

<!-- manifest:start -->
<!-- Made from homelab-stack.json. Change the manifest, not these lines. -->

## Grants

You approve each of these before the stack starts.

- Route: `calibre.<your domain>` to port 8083 in the stack.
- Route: `books.<your domain>` to port 8084 in the stack.
- Storage: the folder in `BOOKS_DIR`, at `/pool/media/books` in the stack, read-write.
- Storage: the folder in `BOOKS_INGEST_DIR`, at `/pool/media/books-ingest` in the stack, read-write.
- Network: out to the host on port 25/tcp.
- Containers: Podman runs in the stack.

## Variables

| Name | Kind | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `BOOKS_DIR` | path | yes |  | The Calibre library. Its owner and group become the stack's books user and media group, which the apps write as. |
| `BOOKS_INGEST_DIR` | path | yes |  | The ingest folder: books dropped here, or fetched by the downloader, are added to the library. |

## Backup

The stack recommends these folders. None is backed up until you add it to a backup.

- Book library: the folder in `BOOKS_DIR`.
- Calibre-Web settings: `/var/lib/calibre-web` in the stack.
  - Without `/processed_books/**`. Copies of books already added to the library.
  - Without `/thumbnails/**`. Cover thumbnails. They are made again.
  - Without `/log_archive/**`. Log files.
  - Without `/.cache/**`. Temporary files.

## Health

An update is kept when all of this holds, and rolled back when it does not.

- `podman-calibre-web.service` is active.
- `podman-calibre-web-downloader.service` is active.

Manifest version 9, built with nixpkgs `nixos-unstable`. Runs on [homelab-ngx](https://github.com/homelab-ngx/homelab-ngx).

<!-- manifest:end -->

## License

MIT, see [LICENSE](LICENSE).
