SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

BEGIN;

ALTER TABLE user_points_records
    MODIFY COLUMN points_change DECIMAL(10, 1) NOT NULL DEFAULT 0.0 COMMENT '积分变动量',
    MODIFY COLUMN change_source VARCHAR(50) NOT NULL COMMENT '积分变动来源',
    MODIFY COLUMN source_detail VARCHAR(255) DEFAULT NULL COMMENT '来源详情',
    MODIFY COLUMN remark VARCHAR(50) DEFAULT NULL COMMENT '备注信息',
    ADD COLUMN is_deleted TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否已删除（0=否, 1=是）' AFTER created_at;

DROP INDEX idx_user ON user_points_records;
CREATE INDEX idx_user_deleted ON user_points_records (user_id, is_deleted);

ALTER TABLE daily_tasks 
    MODIFY COLUMN reward_points DECIMAL(10, 1) NOT NULL DEFAULT 0.0 COMMENT '完成任务奖励的积分';


CREATE TABLE `user_point` (
    `id`           bigint auto_increment                comment 'ID（主键）' primary key,
    `user_id`      bigint                               not null comment '用户ID',
    `total_points` decimal(10, 1) default 0.0           not null comment '用户当前总积分',
    `is_delete`    tinyint(1)     default 0             not null comment '是否已删除（软删除）',
    `created_at`   datetime       default CURRENT_TIMESTAMP not null comment '创建时间（首次登录时创建）',
    `updated_at`   datetime       default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间'
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 comment '用户积分总表';


ALTER TABLE user_task_records
ADD COLUMN business_id bigint NULL COMMENT '业务ID（记录录播视频、直播课堂等的课时id）';

CREATE TABLE user_daily_task_record
(
    id             bigint AUTO_INCREMENT COMMENT '主键ID' PRIMARY KEY,
    user_id        bigint                              NOT NULL COMMENT '用户ID（关联users表）',
    task_id        bigint                              NOT NULL COMMENT '任务ID（关联daily_tasks表）',
    task_date      date                                NOT NULL COMMENT '任务日期（yyyy-MM-dd）',
    completed_count int      DEFAULT 0                NOT NULL COMMENT '当日已完成次数',
    max_count      int      DEFAULT 0                NOT NULL COMMENT '当日最大可完成次数（冗余配置，方便查询）',
    created_at     datetime DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '创建时间',
    updated_at     datetime DEFAULT CURRENT_TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT uk_user_task_date UNIQUE (user_id, task_id, task_date)
) COMMENT '用户每日任务完成次数表（原子更新防超次）' CHARSET = utf8mb4;

CREATE INDEX idx_user_date ON user_daily_task_record (user_id, task_date);
CREATE INDEX idx_task_date ON user_daily_task_record (task_id, task_date);
CREATE INDEX idx_date ON user_daily_task_record (task_date);

DROP INDEX idx_type ON daily_tasks;

ALTER TABLE daily_tasks
    DROP COLUMN task_type,
    ADD COLUMN description TEXT NULL COMMENT '任务详细说明' AFTER task_content;


CREATE TABLE `global_click_stats` (
    `id`           BIGINT AUTO_INCREMENT COMMENT '主键ID',
    `total_count`  INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '5分钟周期内的总点击量',
    `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '统计记录入库时间',

    PRIMARY KEY (`id`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='点击量五分钟汇总表';



ALTER TABLE voting_campaigns
ADD COLUMN reward_points int DEFAULT 0 NOT NULL COMMENT '完成奖励积分' AFTER end_time;


INSERT INTO admin_permissions (
    permission_code_or_path,
    icon,
    permission_name,
    description,
    parent_id,
    root_id,
    belongs_platform,
    permission_type,
    sort_order,
    created_at,
    updated_at
) VALUES (
    'point:daily-task:edit',
    '',
    '编辑',
    '',
    151,
    73,
    1,
    2,
    61,
    '2026-04-16 15:10:22',
    '2026-04-16 15:10:22'
);


INSERT INTO yzxxw_management.admin_permissions (permission_code_or_path, icon, permission_name, description, parent_id,
                                                root_id, belongs_platform, permission_type, sort_order, created_at,
                                                updated_at)
VALUES ('system:user:point_manage', null, '积分管理', null, 152, 78, 1, 2, 79, DEFAULT, DEFAULT);


ALTER TABLE daily_tasks
    ADD COLUMN task_type tinyint DEFAULT 2 NOT NULL COMMENT '任务类型：1=一次性任务，2=每日任务，3=无次数限制任务'
    AFTER reward_points;


CREATE TABLE user_point_exchange_record
(
    id               bigint AUTO_INCREMENT COMMENT '主键ID' PRIMARY KEY,
    user_id          bigint                                NOT NULL COMMENT '用户ID',
    order_no         varchar(500)                          NULL COMMENT '订单编号',
    goods_id         varchar(500)                          NULL COMMENT '礼品ID',
    points_cost      decimal(10,1)                         NULL COMMENT '消耗积分',
    is_deleted       tinyint(1)   DEFAULT 0                NOT NULL COMMENT '是否删除 0=否 1=是',
    created_at       datetime     DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '兑换时间',
    updated_at       datetime     DEFAULT CURRENT_TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT = '用户积分礼品兑换记录表' CHARSET = utf8mb4;




INSERT INTO yzxxw_management.daily_tasks (task_key, daily_max_times, task_content, description, reward_points, task_type, status, sort_order, created_at, updated_at) VALUES ('register', 0, '注册', '一次性注册 +5 分', 5.0, 1, 1, 1, '2026-03-04 10:20:41', '2026-04-17 12:01:23');
INSERT INTO yzxxw_management.daily_tasks (task_key, daily_max_times, task_content, description, reward_points, task_type, status, sort_order, created_at, updated_at) VALUES ('sign_in', 1, '登录小程序', '每次登陆 + 1 分，每日最多 + 1 分', 1.0, 2, 1, 2, '2026-03-04 10:20:41', '2026-04-14 11:16:55');
INSERT INTO yzxxw_management.daily_tasks (task_key, daily_max_times, task_content, description, reward_points, task_type, status, sort_order, created_at, updated_at) VALUES ('complete_profile', 0, '完善个人信息', '一次性加分 完善真实姓名、头像、出生日期 + 10 分', 10.0, 1, 1, 3, '2026-03-04 10:20:41', '2026-04-17 12:01:23');
INSERT INTO yzxxw_management.daily_tasks (task_key, daily_max_times, task_content, description, reward_points, task_type, status, sort_order, created_at, updated_at) VALUES ('course_learning', 10, '课程超市课程学习', '按学习时长积分。每 3 分钟积 1 分，PDF 文档同理。每日最多 + 10 分。', 1.0, 2, 1, 4, '2026-03-04 10:20:41', '2026-04-14 11:16:55');
INSERT INTO yzxxw_management.daily_tasks (task_key, daily_max_times, task_content, description, reward_points, task_type, status, sort_order, created_at, updated_at) VALUES ('citizen_class_enrollment', 2, '市民课堂报名', '每报名一个市民课堂 +1 分，每日最多 +2 分', 1.0, 2, 1, 5, '2026-04-07 11:06:23', '2026-04-14 11:16:55');
INSERT INTO yzxxw_management.daily_tasks (task_key, daily_max_times, task_content, description, reward_points, task_type, status, sort_order, created_at, updated_at) VALUES ('citizen_class_attendance', 0, '市民课堂签到', '课程签到 +1 分', 1.0, 3, 1, 7, '2026-04-07 11:06:23', '2026-04-17 12:01:23');
INSERT INTO yzxxw_management.daily_tasks (task_key, daily_max_times, task_content, description, reward_points, task_type, status, sort_order, created_at, updated_at) VALUES ('share_course', 3, '分享课程', '课程超市 分享课程给朋友、朋友圈，每日最多 + 3 分', 1.0, 2, 1, 9, '2026-04-07 11:06:23', '2026-04-16 17:37:43');
INSERT INTO yzxxw_management.daily_tasks (task_key, daily_max_times, task_content, description, reward_points, task_type, status, sort_order, created_at, updated_at) VALUES ('recorded_video', 0, '录播视频学习', '学习完成后 + 2 分', 2.0, 3, 1, 11, '2026-04-07 11:06:24', '2026-04-17 12:01:23');
INSERT INTO yzxxw_management.daily_tasks (task_key, daily_max_times, task_content, description, reward_points, task_type, status, sort_order, created_at, updated_at) VALUES ('live_video', 0, '进入直播课堂', '直播课程进入一次 + 1 分，每个课堂只能 + 1 分', 1.0, 3, 1, 12, '2026-04-07 11:06:24', '2026-04-17 12:01:23');
INSERT INTO yzxxw_management.daily_tasks (task_key, daily_max_times, task_content, description, reward_points, task_type, status, sort_order, created_at, updated_at) VALUES ('click', 25, '点击操作', '点击操作 1 次 0.2 分，每天上限 5 分', 0.2, 2, 1, 14, '2026-04-07 11:06:24', '2026-04-14 11:16:55');
INSERT INTO yzxxw_management.daily_tasks (task_key, daily_max_times, task_content, description, reward_points, task_type, status, sort_order, created_at, updated_at) VALUES ('online_live_event', 10, '线上直播活动', '线上直播活动（不包含常规课程直播课），按学习时长积分，规则和课程超市学习一致', 1.0, 2, 1, 15, '2026-04-07 11:06:24', '2026-04-14 11:16:55');


ALTER TABLE surveys
MODIFY COLUMN reward_points decimal(10,1) DEFAULT 0.0 NOT NULL COMMENT '完成奖励积分';

ALTER TABLE voting_campaigns
MODIFY COLUMN reward_points decimal(10,1) DEFAULT 0.0 NOT NULL COMMENT '完成奖励积分';


COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
