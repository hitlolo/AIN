CREATE TABLE IF NOT EXISTS gallery (
    hpcontent_id TEXT PRIMARY KEY,
    hp_title TEXT,
    author_id TEXT,
    hp_img_url TEXT,
    hp_img_original_url TEXT,
    hp_author TEXT,
    hp_content TEXT,
    ipad_url TEXT,
    hp_makettime TEXT,
    last_update_date TEXT,
    web_url TEXT,
    praisenum INTEGER,
    sharenum INTEGER,
    commentnum INTEGER
);

CREATE TABLE IF NOT EXISTS author(
    user_id TEXT PRIMARY KEY,
    user_name TEXT,
    web_url TEXT,
    desc TEXT,
    wb_name TEXT
);

CREATE TABLE IF NOT EXISTS essay(
    content_id TEXT PRIMARY KEY,
    hp_title TEXT,
    sub_title TEXT,
    hp_author TEXT,
    auth_it TEXT,
    hp_author_introduce TEXT,
    hp_content TEXT,
    hp_makettime TEXT,
    wb_name TEXT,
    wb_img_url TEXT,
    last_update_date TEXT,
    web_url TEXT,
    guide_word TEXT,
    audio TEXT,
    praisenum INTEGER,
    sharenum INTEGER,
    commentnum INTEGER,
    author TEXT,
    FOREIGN KEY(author) REFERENCES autor(user_id)
);


CREATE TABLE IF NOT EXISTS serial(
    item_id TEXT PRIMARY KEY,
    serial_id TEXT,
    number TEXT,
    title TEXT,
    excerpt TEXT,
    content TEXT,
    charge_edt TEXT,
    read_num TEXT,
    maketime TEXT,
    last_update_date TEXT,
    audio TEXT,
    web_url TEXT,
    input_name TEXT,
    last_update_name TEXT,
    praisenum INTEGER,
    sharenum INTEGER,
    commentnum INTEGER,
    author TEXT,
    FOREIGN KEY(author) REFERENCES autor(user_id)
);



CREATE TABLE IF NOT EXISTS question(
    question_id TEXT PRIMARY KEY,
    question_title TEXT,
    question_content TEXT,
    answer_title TEXT,
    answer_content TEXT,
    question_makettime TEXT,
    recommend_flag TEXT,
    charge_edt TEXT,
    last_update_date TEXT,
    web_url TEXT,
    read_num TEXT,
    praisenum INTEGER,
    sharenum INTEGER,
    commentnum INTEGER
);

CREATE TABLE IF NOT EXISTS elephant(
    article_id TEXT PRIMARY KEY,
    title TEXT,
    headpic TEXT,
    raw_headpic TEXT,
    author TEXT,
    brief TEXT,
    read_num TEXT,
    wechat_url TEXT,
    create_time TEXT,
    update_time TEXT,
    content TEXT
);




