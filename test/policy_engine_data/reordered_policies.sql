UPDATE `site_policies` SET priority = 3 where id = 1;

INSERT INTO `policies` (`id`, `name`, `description`, `created_at`, `updated_at`, `fallback`)
VALUES (3,'Test Matching Policy 2','Test matching policy 2',now(),now(),0);

INSERT INTO `responses` (`id`, `response_attribute`, `value`, `created_at`, `updated_at`, `mac_authentication_bypass_id`, `policy_id`)
VALUES (5,'Reply-Message','Second Policy hit',now(),now(),NULL,3);

INSERT INTO `rules` (`id`, `operator`, `value`, `policy_id`, `request_attribute`, `created_at`, `updated_at`)
VALUES (6,'equals','user@example.org',3,'User-Name',now(),now()),
	(7,'equals','127.0.0.1',3,'NAS-IP-Address',now(),now()),
	(8,'equals','Wireless-802.11',3,'NAS-Port-Type',now(),now());

INSERT INTO `site_policies` (`id`, `site_id`, `policy_id`, `priority`, `created_at`, `updated_at`)
VALUES (3,1,3,1,now(),now());