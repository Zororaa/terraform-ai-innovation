-- seed initial user
INSERT INTO users (user_name, user_email)
VALUES ('Dipanjan Kailthya', 'dipanjan.kailthya@apollotyres.com')
ON CONFLICT DO NOTHING;

-- seed roles
INSERT INTO roles (role_name, role_description)
VALUES
    ('GENYSYS_USER', 'Standard user access'),
    ('GENYSYS_ADMIN', 'Administrator access')
ON CONFLICT DO NOTHING;

-- assign both roles to initial user
INSERT INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u, roles r
WHERE u.user_email = 'dipanjan.kailthya@apollotyres.com'
  AND r.role_name IN ('GENYSYS_USER', 'GENYSYS_ADMIN')
  AND NOT EXISTS (
      SELECT 1 FROM user_roles ur
      WHERE ur.user_id = u.user_id AND ur.role_id = r.role_id
  );


-- grant Super User admin group
INSERT INTO groups_members (group_name, member, description)
SELECT 'Super User', 'dipanjan.kailthya@apollotyres.com', 'Administrator group'
WHERE NOT EXISTS (
    SELECT 1 FROM groups_members
    WHERE group_name = 'Super User'
      AND member = 'dipanjan.kailthya@apollotyres.com'
);
