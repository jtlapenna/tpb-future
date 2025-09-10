docker exec -it aim-tpb-be-api-1 /bin/bash
rails console
# storeId = 1
StoreSyncJob.perform_now(242)