sparksql

1. 查数之前先看一下最新分区 show partitions 表名
2. 分步把数据取出来，这样可以每一步都检查下数据有没有问题，比如看看key有没有重复的
	count()
	distinct().count()
3. show(10,false) 显示10行不缩略
4. 结果保存csv:
	.coalesce(1)
	.toDF()
	.write.option("header","true")
	.csv(s"hdfs://ns1019/user/mart_risk_aof/personal/XXX/XXX")
5. filter：满足条件的保留，不满足条件的过滤（后面写满足的条件）
6. when($"ordering_dates_count_1m"=!=$"ordering_dates_count_1m_2",1).otherwise(0)
	when函数的用法：满足条件的为1，否则为0
	列与列之间的比较用：=!=, ===
7. 建表时，sparksql要把rowformat 那一行去掉
8. 检查join字段能不能join上：把两张表join字段取出来，except
9. Instr：一个字符串在另一个字符串中首次出现的位置
10. TRIM：去除字符串首尾处的空白字符（或者其他字符）. 
11. Lower：变为小写
12. 取json数据的某个值：
	get_json_object(detections,'$$.tao_virgo_rigel_l1_rule_detector') as double

13. spark数据倾斜设置：
	(1). HIVE : Skew join 自动处理数据倾斜的问题
	(2). 小表broadcast 自动Broadcast：spark.conf.set("spark.sql.autoBroadcastJoinThreshold", 10485760)
	(3). 如果表都很大，可以在key上加随机数，数据膨胀
	
	   //计算领券用户最多的二十个注册渠道
	    val reg_user_type_cd_top_20 = reg_user_type_cd_top_all
	      .withColumn("rank", row_number().over(Window.orderBy(desc("user_cnt"))))
	      .filter("rank <= 20")
	      .withColumn("rand", explode(split(lit("1,2,3,4,5"),",")))
	      .withColumn("reg_user_type_cd_rand", concat($"reg_user_type_cd", $"rand"))
	      .cache()
	    //领券用户数top20渠道 base表
	    val jos = jo
	      .withColumn("reg_user_type_cd_rand",concat($"reg_user_type_cd_rand", rand()*5.cast("Int")))
	      .join(reg_user_type_cd_top_20.select("reg_user_type_cd_rand","reg_user_type_cd","rank"), Seq("reg_user_type_cd_rand")).cache()
