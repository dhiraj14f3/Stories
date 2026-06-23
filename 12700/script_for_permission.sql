DO $$
DECLARE
    v_permission_name CONSTANT TEXT := 'Integration Logs';

    v_view_only_name CONSTANT TEXT := 'View Only';
    v_manage_name CONSTANT TEXT := 'Manage';

    v_system_user CONSTANT TEXT := 'System';
    v_permission_type CONSTANT TEXT := 'NONE';

    v_permission_id BIGINT;
    v_permission_view_operation_id BIGINT;
    v_permission_manage_operation_id BIGINT;
BEGIN
    -- Insert Permission: Integration Logs
    INSERT INTO "config".permission (
        name,
        created_at,
        modified_at,
        created_by,
        modified_by,
        permission_type
    )
    SELECT v_permission_name,
           NOW(),
           NOW(),
           v_system_user,
           v_system_user,
           v_permission_type
    WHERE NOT EXISTS (
        SELECT 1
        FROM "config".permission
        WHERE name = v_permission_name
    );

    SELECT id INTO v_permission_id
    FROM "config".permission
    WHERE name = v_permission_name
    LIMIT 1;

    -- Insert View Only Operation
    INSERT INTO "config".permission_operations (
        operation_name,
        permission_id,
        parent_operation_id,
        created_at,
        modified_at,
        created_by,
        modified_by
    )
    SELECT v_view_only_name,
           v_permission_id,
           0,
           NOW(),
           NOW(),
           v_system_user,
           v_system_user
    WHERE NOT EXISTS (
        SELECT 1
        FROM "config".permission_operations
        WHERE operation_name = v_view_only_name
          AND permission_id = v_permission_id
    );

    SELECT id INTO v_permission_view_operation_id
    FROM "config".permission_operations
    WHERE operation_name = v_view_only_name
      AND permission_id = v_permission_id
    LIMIT 1;

    -- Insert Manage Operation
    INSERT INTO "config".permission_operations (
        operation_name,
        permission_id,
        parent_operation_id,
        created_at,
        modified_at,
        created_by,
        modified_by
    )
    SELECT v_manage_name,
           v_permission_id,
           v_permission_view_operation_id,
           NOW(),
           NOW(),
           v_system_user,
           v_system_user
    WHERE NOT EXISTS (
        SELECT 1
        FROM "config".permission_operations
        WHERE operation_name = v_manage_name
          AND permission_id = v_permission_id
    );

END $$;




DO $$
DECLARE
    v_overseeing_name CONSTANT TEXT := 'Overseeing';
    v_program_admin_name CONSTANT TEXT := 'Program Admin';
    v_system_admin_name CONSTANT TEXT := 'System Admin';

    v_permission_name CONSTANT TEXT := 'Integration Logs';

    v_view_only_name CONSTANT TEXT := 'View Only';
    v_manage_name CONSTANT TEXT := 'Manage';

    v_system_user CONSTANT TEXT := 'System';

    v_overseeing_id BIGINT;
    v_program_admin_id BIGINT;
    v_system_admin_id BIGINT;
    v_permission_id BIGINT;
BEGIN
    -- Get Overseeing permission set
    SELECT id INTO v_overseeing_id
    FROM "config".permission_sets
    WHERE permission_set_name = v_overseeing_name
    LIMIT 1;

    IF v_overseeing_id IS NULL THEN
        RAISE EXCEPTION 'Permission set "%" not found in schema %', v_overseeing_name, 'config';
    END IF;

    -- Get Program Admin permission set
    SELECT id INTO v_program_admin_id
    FROM "config".permission_sets
    WHERE permission_set_name = v_program_admin_name
    LIMIT 1;

    IF v_program_admin_id IS NULL THEN
        RAISE EXCEPTION 'Permission set "%" not found in schema %', v_program_admin_name, 'config';
    END IF;

    -- Get System Admin permission set
    SELECT id INTO v_system_admin_id
    FROM "config".permission_sets
    WHERE permission_set_name = v_system_admin_name
    LIMIT 1;

    IF v_system_admin_id IS NULL THEN
        RAISE EXCEPTION 'Permission set "%" not found in schema %', v_system_admin_name, 'config';
    END IF;

    -- Get Integration Logs permission
    SELECT id INTO v_permission_id
    FROM "config".permission
    WHERE name = v_permission_name
    LIMIT 1;

    IF v_permission_id IS NULL THEN
        RAISE EXCEPTION 'Permission "%" not found in schema %', v_permission_name, 'config';
    END IF;

    -- Overseeing -> Integration Logs permission
    INSERT INTO "config".permission_set_mapping (
        permission_set_id,
        operation_id,
        permission_id,
        operation_value,
        created_at,
        modified_at,
        created_by,
        modified_by
    )
    SELECT v_overseeing_id,
           po.id,
           v_permission_id,
           1,
           NOW(),
           NOW(),
           v_system_user,
           v_system_user
    FROM "config".permission_operations po
    WHERE po.permission_id = v_permission_id
      AND po.operation_name IN (v_view_only_name, v_manage_name)
      AND NOT EXISTS (
          SELECT 1
          FROM "config".permission_set_mapping m
          WHERE m.permission_set_id = v_overseeing_id
            AND m.permission_id = v_permission_id
            AND m.operation_id = po.id
      );

    -- Program Admin -> Integration Logs permission
    INSERT INTO "config".permission_set_mapping (
        permission_set_id,
        operation_id,
        permission_id,
        operation_value,
        created_at,
        modified_at,
        created_by,
        modified_by
    )
    SELECT v_program_admin_id,
           po.id,
           v_permission_id,
           1,
           NOW(),
           NOW(),
           v_system_user,
           v_system_user
    FROM "config".permission_operations po
    WHERE po.permission_id = v_permission_id
      AND po.operation_name IN (v_view_only_name, v_manage_name)
      AND NOT EXISTS (
          SELECT 1
          FROM "config".permission_set_mapping m
          WHERE m.permission_set_id = v_program_admin_id
            AND m.permission_id = v_permission_id
            AND m.operation_id = po.id
      );

    -- System Admin -> Integration Logs permission
    INSERT INTO "config".permission_set_mapping (
        permission_set_id,
        operation_id,
        permission_id,
        operation_value,
        created_at,
        modified_at,
        created_by,
        modified_by
    )
    SELECT v_system_admin_id,
           po.id,
           v_permission_id,
           1,
           NOW(),
           NOW(),
           v_system_user,
           v_system_user
    FROM "config".permission_operations po
    WHERE po.permission_id = v_permission_id
      AND po.operation_name IN (v_view_only_name, v_manage_name)
      AND NOT EXISTS (
          SELECT 1
          FROM "config".permission_set_mapping m
          WHERE m.permission_set_id = v_system_admin_id
            AND m.permission_id = v_permission_id
            AND m.operation_id = po.id
      );

END $$ LANGUAGE plpgsql;