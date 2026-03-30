job "duckdns" {
  datacenters = ["dc1"]
  type        = "batch"

  periodic {
    crons            = ["*/5 * * * *"]
    prohibit_overlap = true
    time_zone        = "Europe/London"
  }

  group "dynamic-dns" {
		task "setup" {
			driver = "raw_exec"
			config {
				command = "sh"
				args    = ["-c", "exec cp -f $NOMAD_TASK_DIR/duckdns.sh /usr/local/bin/duckdns"]
			}

			template {
				data        = file("nomad/jobs/scripts/duckdns.sh")
				destination = "local/duckdns.sh"
				perms       = "755"
			}

			lifecycle {
				hook    = "prestart"
				sidecar = false
			}

			resources {
				cpu    = 50
				memory = 64
			}
		}

    task "update" {
      driver = "raw_exec"

      config {
        command = "sh"
        args    = ["-c", "exec duckdns"]
      }

      resources {
        cpu    = 50
        memory = 64
      }
    }
  }

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "freebsd"
  }
}
