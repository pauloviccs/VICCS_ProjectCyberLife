USE open77_lifesim;

CREATE TABLE IF NOT EXISTS ls_cyberware (
    license      CHAR(32)  NOT NULL,
    data         JSON      NOT NULL,
    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (license),
    CONSTRAINT fk_ls_cyberware_license FOREIGN KEY (license) REFERENCES ls_players(license) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SHOW TABLES;
