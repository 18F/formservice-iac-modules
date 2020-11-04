# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/documentdb outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "cluster_name" {
  value       = module.documentdb_cluster.cluster_name
  description = "DocumentDB Cluster Identifier"
}

output "master_username" {
  value       = module.documentdb_cluster.master_username
  description = "DocumentDB Username for the master DB user"
}


