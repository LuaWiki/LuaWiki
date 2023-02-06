dbconf = {
	host = os.getenv("MYSQL_HOST"),
	port = tonumber(os.getenv("MYSQL_PORT") or '3306', 10) or 3306,
	database = os.getenv("MYSQL_DB"),
	user = os.getenv("MYSQL_USER"),
	password = os.getenv("MYSQL_PASSWORD"),
	charset = "utf8mb4",
	max_packet_size = 1024 * 1024,
}