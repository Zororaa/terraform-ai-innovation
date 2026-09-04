-- seed initial user
INSERT INTO users (user_name, user_email)
VALUES
    ('Dipanjan Kailthya', 'dipanjan.kailthya@apollotyres.com'),
    ('Willem van der Spek', 'willem.vanderspek@apollotyres.com'),
    ('Christine Nakatani', 'christine.nakatani@apollotyres.com')
ON CONFLICT DO NOTHING;

-- seed roles
INSERT INTO roles (role_name, role_description)
VALUES
    ('ATLAS_USER', 'Standard user access'),
    ('ATLAS_ADMIN', 'Administrator access')
ON CONFLICT DO NOTHING;

-- assign roles to users
INSERT INTO user_roles (user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u, roles r
WHERE u.user_email IN (
    'dipanjan.kailthya@apollotyres.com',
    'willem.vanderspek@apollotyres.com',
    'christine.nakatani@apollotyres.com'
  )
  AND r.role_name IN ('ATLAS_USER', 'ATLAS_ADMIN')
  AND NOT EXISTS (
      SELECT 1 FROM user_roles ur
      WHERE ur.user_id = u.user_id AND ur.role_id = r.role_id
  );

-- grant Super User admin group
INSERT INTO groups_members (group_name, member, description)
SELECT 'Super User', member, 'Administrator group'
FROM (VALUES
    ('dipanjan.kailthya@apollotyres.com'),
    ('willem.vanderspek@apollotyres.com'),
    ('christine.nakatani@apollotyres.com')
) AS v(member)
WHERE NOT EXISTS (
    SELECT 1 FROM groups_members gm
    WHERE gm.group_name = 'Super User'
      AND gm.member = v.member
);
