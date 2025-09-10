
# Drop the current database.
docker exec -i aim-tpb-be-db-1 psql -U tpb -d postgres -c "DROP DATABASE IF EXISTS tpb_api;"

# Create a new database and restore the backup.
docker exec -i aim-tpb-be-db-1 psql -U tpb -d postgres -c "CREATE DATABASE tpb_api;"

# Copy the backup file to the container.
docker cp ../backup-api_prod_rds-1738053001.sql aim-tpb-be-db-1:/tmp/backup.dump

# Restore the backup.
docker exec -i aim-tpb-be-db-1 pg_restore -U tpb -d tpb_api --single-transaction --no-owner -v /tmp/backup.dump

# Run Rails migrations.
docker exec -i aim-tpb-be-api-1 rails db:migrate RAILS_ENV=development

# Update the password for the admin user.
docker exec -i aim-tpb-be-db-1 psql -U tpb -d tpb_api -c "UPDATE public.users SET password_digest='\$2a\$12\$Q4rnMnSfFtNu02Y3z27YNOBJSbyCgdc71A90WJsoEPd.xq7TOWpx6', active=true WHERE email='admin@admin.org';"

# Use https://bcrypt-generator.com/ with rounds 12 to generate a password hash

# "secure_password" -> $2a$12$Q4rnMnSfFtNu02Y3z27YNOBJSbyCgdc71A90WJsoEPd.xq7TOWpx6
# UPDATE public.users
 # SET password_digest='hash'
 # WHERE email='admin@admintpb.org';
#



