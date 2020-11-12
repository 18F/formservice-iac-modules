# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/documentdb outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "cluster_name" {
  value       = module.documentdb_cluster.cluster_name
  description = "DocumentDB Cluster Identifier"
}

output "endpoint" {
  value       = module.documentdb_cluster.endpoint
  description = "Endpoint of the DocumentDB cluster"
}

output "master_username" {
  value       = module.documentdb_cluster.master_username
  description = "DocumentDB Username for the master DB user"
}


