import os

config = {
    "$webservergroup": 'www-data',
    "$db_driver": os.environ.get("DB_DRIVER", 'mysql'),
    "$db_host": os.environ.get("DB_HOST", 'host.docker.internal'),
    "$db_name": os.environ.get("DB_NAME", "bugs"),
    "$db_user": os.environ.get("DB_USER", "bugzilla"),
    "$db_pass": os.environ.get("DB_PASS", ""),
    "$db_port": os.environ.get("DB_PORT", 0)
}
admin_detail = {
    r'$answer{ADMIN_EMAIL}': os.environ.get("ADMIN_EMAIL"),
    r'$answer{ADMIN_PASSWORD}': os.environ.get("ADMIN_PASSWORD"),
    r'$answer{ADMIN_REALNAME}': os.environ.get("ADMIN_EMAIL"),
}


config_content = None
with open("localconfig", 'r') as e:
    config_content = e.read()


if config_content is None:
    raise ValueError()
if len(admin_detail.get(r"$answer{ADMIN_PASSWORD}")) < 6:
    raise ValueError(
        "Admin password too short. (at least 6 characters)")

for lines in open("localconfig", 'r').readlines():
    for k, v in config.items():
        if lines.find(k) == 0:
            if k == '$db_port':
                config_content = config_content.replace(
                    lines, "{key} = {value};\n".format(key=k, value=v), 1)
                break
            config_content = config_content.replace(
                lines, "{key} = '{value}';\n".format(key=k, value=v), 1)
            break

# for checksetup script
admin_config = ''
for k, v in admin_detail.items():
    admin_config += "{key} = '{value}';\n".format(
        key=k,
        value=v
    )
admin_config += "$answer{NO_PAUSE} = 1\n"

with open("localconfig", 'w') as e:
    e.write(config_content)
with open("adminconfig", 'w') as e:
    e.write(admin_config)
