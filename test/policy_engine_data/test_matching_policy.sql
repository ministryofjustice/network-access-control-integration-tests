SET FOREIGN_KEY_CHECKS = 0; 
truncate table rules;
truncate table responses;
truncate table site_policies;
truncate table policies;
truncate table sites;
truncate table clients;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO `sites` (`id`, `tag`, `name`, `created_at`, `updated_at`)
VALUES
  (1,'test_client','Probation Site 1',now(),now());

INSERT INTO `clients` (`id`, `shared_secret`, `ip_range`, `site_id`, `created_at`, `updated_at`)
VALUES
   (1,'test','10.5.0.6/32',1,now(),now());

INSERT INTO `policies` (`id`, `name`, `description`, `created_at`, `updated_at`, `fallback`)
VALUES
  (1,'Test Matching Policy','Test Matching Policy',now(),now(),0),
  (2,'Fallback','Some fallback policy',now(),now(),1),
  (3,'Prioritised policy','Prioritised policy',now(),now(),0);

INSERT INTO `site_policies` (`id`, `site_id`, `policy_id`, `priority`, `created_at`, `updated_at`)
VALUES
  (1,1,1,2,now(),now()),
  (2,1,2,3,now(),now()),
  (3,1,3,4,now(),now());

INSERT INTO `responses` (`id`, `response_attribute`, `value`, `created_at`, `updated_at`, `mac_authentication_bypass_id`, `policy_id`)
VALUES
  (1,'Tunnel-Type','VLAN',now(),now(),NULL,1),
  (2,'Tunnel-Medium-Type','IEEE-802',now(),now(),NULL,1),
  (3,'Tunnel-Private-Group-Id','777',now(),now(),NULL,1),
  (4,'Reply-Message','Fallback Policy',now(),now(),NULL,2),
  (5,'Reply-Message','Prioritised Policy hit',now(),now(),NULL,3);


INSERT INTO `rules` (`id`, `operator`, `value`, `policy_id`, `request_attribute`, `created_at`, `updated_at`)
VALUES
  (1,'equals','user@example.org',1,'User-Name',now(),now()),
  (2,'equals','127.0.0.1',1,'NAS-IP-Address',now(),now()),
  (5,'equals','Wireless-802.11',1,'NAS-Port-Type',now(),now()),
  (6,'equals','user@example.org',3,'User-Name',now(),now()),
  (7,'equals','127.0.0.1',3,'NAS-IP-Address',now(),now()),
  (8,'equals','Wireless-802.11',3,'NAS-Port-Type',now(),now());
