{ config, lib, ... }:

# Calibre-Web-Automated (library, reader, Send-to-Kindle) and its book
# downloader, under podman inside the stack (the containers grant). The
# downloader puts books in the ingest folder; CWA adds them to the library.
# Send-to-Kindle mails through the homelab host's relay: in CWA's settings
# the mail server is the host's address on the stack network, the gateway
# (`ip route` in the stack), port 25, no encryption.
#
# The homelab daemon's host module gives the books user and the media group
# the ids of the library folder, and opens the routes' ports.

let
  tz = config.time.timeZone or "UTC";
  # The ids the containers write as. Without the daemon (a plain build) the
  # host module is absent and they fall back to 1000.
  uid = toString (if config.users.users.books.uid != null then config.users.users.books.uid else 1000);
  gid = toString (if config.users.groups.media.gid != null then config.users.groups.media.gid else 1000);
in
{
  users.users.books = {
    isSystemUser = true;
    group = "media";
  };
  users.groups.media = { };

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  systemd.tmpfiles.rules = [ "d /var/lib/calibre-web 0755 books media -" ];

  virtualisation.oci-containers.containers = {
    calibre-web = {
      # 3.x, e8a527a2-ls87
      image = "docker.io/crocodilestick/calibre-web-automated@sha256:5e00373854247750cc3e4479b492ae09293ff5e06ed10177f226634d97888679";
      ports = [ "8083:8083" ];
      environment = {
        PUID = uid;
        PGID = gid;
        TZ = tz;
      };
      volumes = [
        "/var/lib/calibre-web:/config"
        "/pool/media/books:/calibre-library"
        "/pool/media/books-ingest:/cwa-book-ingest"
      ];
    };

    calibre-web-downloader = {
      # 1.7.0
      image = "ghcr.io/calibrain/calibre-web-automated-book-downloader@sha256:6544e02595271b0267b9acda58fa7f3db6f14942bece51b7aadfe4000cf34f1c";
      ports = [ "8084:8084" ];
      environment = {
        TZ = tz;
        UID = uid;
        GID = gid;
        FLASK_PORT = "8084";
        INGEST_DIR = "/cwa-book-ingest";
      };
      volumes = [ "/pool/media/books-ingest:/cwa-book-ingest" ];
    };
  };
}
