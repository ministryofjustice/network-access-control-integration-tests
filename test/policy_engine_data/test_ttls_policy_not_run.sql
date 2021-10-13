SET FOREIGN_KEY_CHECKS = 0; 
truncate table rules;
truncate table responses;
truncate table site_policies;
truncate table policies;
truncate table sites;
truncate table clients;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO `sites` (`id`, `name`, `created_at`, `updated_at`)
VALUES
  (1,'Test TTLS Site 1',now(),now());

INSERT INTO `clients` (`id`, `tag`, `shared_secret`, `ip_range`, `site_id`, `created_at`, `updated_at`)
VALUES
   (1,'test_client','test','10.5.0.6/32',1,now(),now());

INSERT INTO `policies` (`id`, `name`, `description`, `created_at`, `updated_at`, `fallback`)
VALUES
  (1,'Test TTLS Policy','Test TTLS Policy',now(),now(),0);

INSERT INTO `site_policies` (`id`, `site_id`, `policy_id`, `priority`, `created_at`, `updated_at`)
VALUES
  (1,1,1,1,now(),now());

INSERT INTO `responses` (`id`, `response_attribute`, `value`, `created_at`, `updated_at`, `mac_authentication_bypass_id`, `policy_id`)
VALUES
  (1,'Reply-Message','TTLS Policy Matched',now(),now(),NULL,1);

INSERT INTO `rules` (`id`, `operator`, `value`, `policy_id`, `request_attribute`, `created_at`, `updated_at`)
VALUES
  (1,'equals','EAP-Type',1,'TTLS',now(),now());
