-- meal_slot_configs에 슬롯 이름 배열 추가 (아침, 간식, 점심 등)
alter table meal_slot_configs add column if not exists slot_names jsonb default '[]';

-- daily_logs에 체크된 슬롯 이름 배열 추가
alter table daily_logs add column if not exists meal_checked jsonb default '[]';
