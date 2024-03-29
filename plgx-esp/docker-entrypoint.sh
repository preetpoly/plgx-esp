#!/bin/bash
echo "Starting docker entry point script..."


echo "Waiting for PostgreSQL to start..."
while ! nc -z "$POSTGRES_ADDRESS" "$POSTGRES_PORT"; do sleep 7; done

file="/tmp/celerybeat.pid"

if [ -f $file ] ; then
    rm $file
fi


TARGET=/usr/local/lib/python3.7/site-packages/celery/backends
cd $TARGET
if [ -e async.py ]
then
    mv async.py asynchronous.py
    sed -i 's/async/asynchronous/g' redis.py
    sed -i 's/async/asynchronous/g' rpc.py
fi
CORES=1
if [[ "$OSTYPE" == "linux-gnu" ]]; then
        CORES="$(nproc --all)"
elif [[ "$OSTYPE" == "darwin"* ]]; then
        CORES="$(sysctl -n hw.ncpu)"         
elif [[ "$OSTYPE" == "cygwin" ]]; then
		echo "Os is cygwin.."
        # POSIX compatibility layer and Linux environment emulation for Windows
elif [[ "$OSTYPE" == "msys" ]]; then
		echo "Os is msys.."
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
elif [[ "$OSTYPE" == "win32" ]]; then
		CORES=echo %NUMBER_OF_PROCESSORS%
        # I'm not sure this can happen.
elif [[ "$OSTYPE" == "freebsd"* ]]; then
        CORES="$(sysctl -n hw.ncpu)"         
 else
		echo "Os is unknown.."
fi
cd /src/plgx-esp
[ -f resources/certificate.crt ] && echo "PolyLogyx fleet is configured for SSL" || echo "PolyLogyx Fleet is not configured for SSL, please run certificate-generate.sh or use OpenSSL to create key pair. Check deployment guide for more info..."

echo "Creating enroll file..."
exec `echo "$ENROLL_SECRET">resources/secret.txt`

echo "Creating celery tmux sessions..."
exec `tmux new-session -d -s plgx_celery`
exec `tmux new-session -d -s plgx_celery_result_log`
exec `tmux new-session -d -s plgx_celery_beat`
exec `tmux new-session -d -s plgx_gunicorn`
exec `tmux new-session -d -s celery_rlbicwa`
exec `tmux new-session -d -s flower`




CORES="$(nproc --all)"
echo "CPU cores are $CORES"
WORKERS=$(( 2*CORES  ))
WORKERS_CELERY=$(( 8*CORES  ))
WORKERS_REDIS=$(( 2*CORES  ))

echo "Creating DB schema..."
python manage.py db upgrade

echo "Creating default user..."
exec `tmux send -t plgx_celery 'python manage.py add_user  "$POLYLOGYX_USER" --password  "$POLYLOGYX_PASSWORD"' ENTER`
echo "Adding default configs..."
exec `tmux send -t plgx_celery 'python manage.py add_default_config default_config_windows --filepath default_data/default_configs/default_config_windows.conf --platform windows' ENTER`
exec `tmux send -t plgx_celery 'python manage.py add_default_config default_config_macos --filepath default_data/default_configs/default_config_macos.conf --platform darwin' ENTER`
exec `tmux send -t plgx_celery 'python manage.py add_default_config default_config_linux --filepath default_data/default_configs/default_config_linux.conf --platform linux' ENTER`
exec `tmux send -t plgx_celery 'python manage.py add_default_config default_config_freebsd --filepath default_data/default_configs/default_config_freebsd.conf --platform freebsd' ENTER`
exec `tmux send -t plgx_celery 'python manage.py add_default_options' ENTER`
echo "Adding default filters..."

exec `tmux send -t plgx_celery 'python manage.py add_default_filters --filepath default_data/default_filters/default_filter_linux.conf --platform linux' ENTER`
exec `tmux send -t plgx_celery 'python manage.py add_default_filters --filepath default_data/default_filters/default_filter_macos.conf --platform darwin' ENTER`
exec `tmux send -t plgx_celery 'python manage.py add_default_filters --filepath default_data/default_filters/default_filter_windows.conf --platform windows' ENTER`
echo "Adding default queries..."

exec `tmux send -t plgx_celery 'python manage.py add_default_queries --filepath default_data/default_queries/default_queries_linux.conf --platform linux' ENTER`
exec `tmux send -t plgx_celery 'python manage.py add_default_queries --filepath default_data/default_queries/default_queries_macos.conf --platform darwin' ENTER`
exec `tmux send -t plgx_celery 'python manage.py add_default_queries --filepath default_data/default_queries/default_queries_windows.conf --platform windows' ENTER`


echo "Adding default mitre rules..."
for entry in /src/plgx-esp/default_data/mitre-attack/*
do
  packname=$(basename "$entry" .json)
  echo $packname
  exec `tmux send -t plgx_celery 'python manage.py add_rules  --filepath '"$entry" ENTER`
done

echo "Adding default query packs..."
for entry in /src/plgx-esp/default_data/packs/*
do
  packname=$(basename "$entry" .conf)
  echo $packname
  exec `tmux send -t plgx_celery 'python manage.py addpack ' $packname ' --filepath '"$entry" ENTER`
done

cd /src/plgx-esp
echo "Starting celery beat..."
exec `tmux send -t plgx_celery_beat 'celery beat -A polylogyx.worker:celery   --schedule=/tmp/celerybeat-schedule --loglevel=INFO --pidfile=/tmp/celerybeat.pid' ENTER`
echo "Starting celery RabbitMQ..."
exec `tmux send -t celery_rlbicwa "python workerResultLog.py &" ENTER`

exec `tmux send -t plgx_celery_result_log "celery worker -A polylogyx.worker:celery --concurrency=$WORKERS_CELERY -Q result_log_queue -l INFO &" ENTER`

echo "Starting PolyLogyx Vasp osquery fleet manager..."
exec `tmux send -t plgx_gunicorn "gunicorn -w $WORKERS -k gevent --worker-connections 10 --bind 0.0.0.0:6000   manage:app --reload" ENTER`

if [[ -z "$PURGE_DATA_DURATION" ]]
then
  echo "PURGE_DATA_DURATION value is not set, data will not be purged automatically!"
else
  echo "Setting auto database purge duration..."
  exec `tmux send -t plgx_celery 'python manage.py delete_historical_data --purge_data_duration '"$PURGE_DATA_DURATION" ENTER`
fi
exec `tmux send -t plgx_celery "celery worker -A polylogyx.worker:celery --concurrency=$WORKERS_CELERY -Q default_queue_tasks --max-memory-per-child=250000 -l INFO &" ENTER`

echo "Sever is up and running.."
exec `tmux send -t flower "flower -A polylogyx.worker:celery --address=0.0.0.0  --broker_api=http://guest:guest@$RABBITMQ_URL:5672/api --basic_auth=$POLYLOGYX_USER:$POLYLOGYX_PASSWORD" ENTER`

exec `tail -f /dev/null`
