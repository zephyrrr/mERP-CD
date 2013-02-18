CREATE function [dbo].[Get_StrArrayStrOfIndex]
(
	@str varchar(1024),--要分割的字符串
	@split varchar(10),--分割符号
	@index int--取第几个元素
)
returns varchar(1024)
as
begin
--按指定符号分割字符串，返回分割后指定索引的第几个元素，下标从1开始
--示例：select Get_StrArrayStrOfIndex('8,9,5',',',2)
--返回值：9
	declare @location int
	declare @start int
	declare @next int
	declare @seed int

	set @str = ltrim(rtrim(@str))
	set @start = 1
	set @next = 1
	set @seed = len(@split)

	set @location = charindex(@split, @str)
	while @location <> 0 and @index > @next
	begin
		set @start = @location + @seed
		set @location = charindex(@split, @str, @start)
		set @next = @next + 1
	end
	if @location = 0 select @location = len(@str) + 1

	return substring(@str, @start, @location - @start)
end
CREATE function [dbo].[函数查询_产值费用项](@id uniqueidentifier)
returns table
as
return
(
	select b.警示状态,a.编号 as 费用项, SeqNo, d.Id as 车辆产值, d.费用实体类型 as 业务类型, b.Submitted, b.完全标志付,
			--委托人应收
			(SELECT     SUM(case when E.收付标志 = 1 then E.金额 when E.收付标志 = 2 then 0-E.金额 else 0 end) AS Expr1 
			FROM         dbo.财务_费用 AS E LEFT OUTER JOIN
								  dbo.财务_对账单 AS F ON E.对账单 = F.Id
			where e.费用实体=d.id and e.费用项=a.编号 and e.费用归属 = 1 AND (E.凭证费用明细 IS NOT NULL OR f.submitted =1)) as 委托人应收,
			--委托人拟收
			(select SUM(case when E.收付标志 = 1 then E.金额 when E.收付标志 = 2 then 0-E.金额 else 0 end) as 拟收金额 from 财务_费用 E 
				where 费用类型 = 21 and 费用归属 = 1 
				and 费用实体 = d.id and 费用项 = a.编号) as 委托人拟收,
			--车主应付
			(SELECT     SUM(case when (E.收付标志 = 2 and e.车辆承担 = 0) or (E.收付标志 = 1 and e.车辆承担 = 1) then E.金额 else 0-E.金额 end) AS Expr1
			FROM         dbo.财务_费用 AS E LEFT OUTER JOIN
								  dbo.财务_对账单 AS F ON E.对账单 = F.Id
			where e.费用实体=d.id and e.费用项=a.编号 AND (E.凭证费用明细 IS NOT NULL OR f.submitted =1) 
			 and (e.费用归属 = 2 or e.车辆承担 = 1)) as 车主应付,
			--车主拟付
			(select SUM(case when (E.收付标志 = 2 and e.车辆承担 = 0) or (E.收付标志 = 1 and e.车辆承担 = 1) then E.金额 else 0-E.金额 end) as 拟收金额 from 财务_费用 E
				where 费用类型 = 21 and 费用实体 = d.id and 费用项 = a.编号
				 and (费用归属 = 2 or 车辆承担 = 1)) as 车主拟付,
			--驾驶员应付
			(SELECT     SUM(case when E.收付标志 = 2 then E.金额 when E.收付标志 = 1 then 0-E.金额 else 0 end) AS Expr1
			FROM         dbo.财务_费用 AS E LEFT OUTER JOIN
								  dbo.财务_对账单 AS F ON E.对账单 = F.Id
			where e.费用实体=d.id and e.费用项=a.编号 and e.费用归属 = 3 AND (E.凭证费用明细 IS NOT NULL OR f.submitted =1)) as 驾驶员应付,
			--驾驶员拟付
			(select SUM(case when E.收付标志 = 2 then E.金额 when E.收付标志 = 1 then 0-E.金额 else 0 end) as 拟收金额 from 财务_费用 E
				where 费用类型 = 21 and 费用归属 = 3 
				and 费用实体 = d.id and 费用项 = a.编号) as 驾驶员拟付,	
			--对外应付
			(SELECT     SUM(case when E.收付标志 = 2 then E.金额 when E.收付标志 = 1 then 0-E.金额 else 0 end) AS Expr1
			FROM         dbo.财务_费用 AS E LEFT OUTER JOIN
								  dbo.财务_对账单 AS F ON E.对账单 = F.Id
			where e.费用实体=d.id and e.费用项=a.编号 and e.费用归属 = 4 AND (E.凭证费用明细 IS NOT NULL OR f.submitted =1)) as 对外应付,
			--对外拟付
			(select SUM(case when E.收付标志 = 2 then E.金额 when E.收付标志 = 1 then 0-E.金额 else 0 end) as 拟收金额 from 财务_费用 E
				where 费用类型 = 21 and 费用归属 = 4 
				and 费用实体 = d.id and 费用项 = a.编号) as 对外拟付	
	FROM         dbo.参数备案_费用项 AS a INNER JOIN
                      dbo.财务_费用实体 AS d ON d.Id =@id and a.现有费用实体类型 LIKE '%'+convert(varchar(2),d.费用实体类型)+'%' LEFT OUTER JOIN
                      dbo.财务_费用信息 AS b ON a.编号 = b.费用项 AND d.Id = b.车辆产值
)



CREATE function [dbo].[函数查询_业务费用小计_产值费用项](@id uniqueidentifier)
returns table
as
return
(
	SELECT     a.编号 as 费用项, SeqNo, d.Id as 费用实体, d.费用实体类型 as 业务类型, b.Submitted, b.完全标志付,
	--已收金额
	(SELECT     SUM(E.金额) AS Expr1 
	FROM         dbo.财务_费用 AS E 
	where e.费用实体=d.id and e.费用项=a.编号 and E.收付标志 = 1  AND (E.凭证费用明细 IS NOT NULL)) as 已收金额,
	--已付金额
	(SELECT     SUM(E.金额) AS Expr1
	FROM         dbo.财务_费用 AS E 
	where e.费用实体=d.id and e.费用项=a.编号 and E.收付标志 = 2  AND (E.凭证费用明细 IS NOT NULL)) as 已付金额,

	--应收金额
	(SELECT     SUM(E.金额) AS Expr1 
	FROM         dbo.财务_费用 AS E LEFT OUTER JOIN
						  dbo.财务_对账单 AS F ON E.对账单 = F.Id
	where e.费用实体=d.id and e.费用项=a.编号 and E.收付标志 = 1  AND (E.凭证费用明细 IS NOT NULL OR f.submitted =1)) as 应收金额,
	--应付金额
	(SELECT     SUM(E.金额) AS Expr1
	FROM         dbo.财务_费用 AS E LEFT OUTER JOIN
						  dbo.财务_对账单 AS F ON E.对账单 = F.Id
	where e.费用实体=d.id and e.费用项=a.编号 and E.收付标志 = 2  AND (E.凭证费用明细 IS NOT NULL OR f.submitted =1)) as 应付金额,
	--拟收金额
	(select sum(金额) as 拟收金额 from 财务_费用 
		where 费用类型 = 1 and 收付标志 = 1 
		and 费用实体 = d.id and 费用项 = a.编号) as 拟收金额,  
	--拟付金额
	(select sum(金额) as 拟收金额 from 财务_费用 
		where 费用类型 = 1 and 收付标志 = 2
		and 费用实体 = d.id and 费用项 = a.编号) as 拟付金额,
	--理论收
	(select sum(金额) as 理论收金额 from 财务_业务费用理论值 
		where 收付标志 = 1 and 费用实体 = d.id and 费用项 = a.编号) as 理论收金额,
	--理论收
	(select sum(金额) as 理论收金额 from 财务_业务费用理论值 
		where 收付标志 = 2 and 费用实体 = d.id and 费用项 = a.编号) as 理论付金额	
	FROM         dbo.参数备案_费用项 AS a INNER JOIN
                      dbo.财务_费用实体 AS d ON d.Id =@id and a.现有费用实体类型 LIKE '%'+convert(varchar(2),d.费用实体类型)+'%' LEFT OUTER JOIN
                      dbo.财务_费用信息 AS b ON a.编号 = b.费用项 AND d.Id = b.车辆产值
)




CREATE function [dbo].[函数查询_业务费用小计_产值费用项_子](@id uniqueidentifier)
returns table
as
return
(
	SELECT     a.编号 as 费用项, a.SeqNo, d.Id as 费用实体, d.费用实体类型 as 业务类型, b.Submitted, b.完全标志付,
	--已收金额
	(SELECT     SUM(E.金额) AS Expr1 
	FROM         dbo.财务_费用 AS E 
	where e.费用实体=d.id and e.费用项=a.编号 and E.收付标志 = 1  AND (E.凭证费用明细 IS NOT NULL)) as 已收金额,
	--已付金额
	(SELECT     SUM(E.金额) AS Expr1
	FROM         dbo.财务_费用 AS E 
	where e.费用实体=d.id and e.费用项=a.编号 and E.收付标志 = 2  AND (E.凭证费用明细 IS NOT NULL)) as 已付金额,

	--应收金额
	(SELECT     SUM(E.金额) AS Expr1 
	FROM         dbo.财务_费用 AS E LEFT OUTER JOIN
						  dbo.财务_对账单 AS F ON E.对账单 = F.Id
	where e.费用实体=d.id and e.费用项=a.编号 and E.收付标志 = 1  AND (E.凭证费用明细 IS NOT NULL OR f.submitted =1)) as 应收金额,
	--应付金额
	(SELECT     SUM(E.金额) AS Expr1
	FROM         dbo.财务_费用 AS E LEFT OUTER JOIN
						  dbo.财务_对账单 AS F ON E.对账单 = F.Id
	where e.费用实体=d.id and e.费用项=a.编号 and E.收付标志 = 2  AND (E.凭证费用明细 IS NOT NULL OR f.submitted =1)) as 应付金额,
	--拟收金额
	(select sum(金额) as 拟收金额 from 财务_费用 
		where 费用类型 = 1 and 收付标志 = 1 
		and 费用实体 = d.id and 费用项 = a.编号) as 拟收金额,  
	--拟付金额
	(select sum(金额) as 拟收金额 from 财务_费用 
		where 费用类型 = 1 and 收付标志 = 2
		and 费用实体 = d.id and 费用项 = a.编号) as 拟付金额,
	--理论收
	(select sum(金额) as 理论收金额 from 财务_业务费用理论值 
		where 收付标志 = 1 and 费用实体 = d.id and 费用项 = a.编号) as 理论收金额,
	--理论收
	(select sum(金额) as 理论收金额 from 财务_业务费用理论值 
		where 收付标志 = 2 and 费用实体 = d.id and 费用项 = a.编号) as 理论付金额	
	FROM         dbo.参数备案_费用项 AS a INNER JOIN
                      dbo.财务_费用实体 AS d ON d.Id =@id and a.现有费用实体类型 LIKE '%'+convert(varchar(2),d.费用实体类型)+'%' LEFT OUTER JOIN
                      dbo.财务_费用信息 AS b ON a.编号 = b.费用项 AND d.Id = b.车辆产值
)






CREATE function [dbo].[函数查询统计_借贷](@入账日期Ge datetime='2005-1-1',@入账日期Le datetime='2020-12-31')
returns table
as
return
(
	select 相关人,类型,
sum(case when 日期 < @入账日期Ge then isnull(金额,0) else 0 end)  as 月初值,
	sum(case when 日期 >= @入账日期Ge and 日期 <= @入账日期Le and 金额 > 0 then 金额 else 0 end) as 本月新增,
    sum(case when 日期 >= @入账日期Ge and 日期 <= @入账日期Le and 金额 < 0 then -金额 else 0 end) as 本月减少 ,
sum(case when 日期 <= @入账日期Le then isnull(金额,0) else 0 end) as 月末值
from 视图查询_借贷 
    group by 相关人,类型
	
)









CREATE function [dbo].[函数查询统计_投资](@入账日期Ge datetime='2005-1-1',@入账日期Le datetime='2020-12-31')
returns table
as
return
(
	select 相关人,类型,
sum(case when 入账日期 < @入账日期Ge then isnull(投资金额,0) -isnull(撤资金额,0) else 0 end)  as 月初值,
	sum(case when 入账日期 >= @入账日期Ge and 入账日期 <= @入账日期Le then isnull(投资金额,0) else 0 end) as 本月新增,
    sum(case when 入账日期 >= @入账日期Ge and 入账日期 <= @入账日期Le then isnull(撤资金额,0) else 0 end) as 本月减少 ,
sum(case when 入账日期 <= @入账日期Le then isnull(投资金额,0) -isnull(撤资金额,0) else 0 end) as 月末值
from 视图查询_费用明细_费用类型_非业务_投资 
    group by 相关人,类型
	
)











CREATE function [dbo].[函数查询统计_押金](@入账日期Ge datetime='2005-1-1',@入账日期Le datetime='2020-12-31')
returns table
as
return
(
	select 相关人,类型,
sum(case when 日期 < @入账日期Ge then isnull(金额,0) else 0 end)  as 月初值,
	sum(case when 日期 >= @入账日期Ge and 日期 <= @入账日期Le and 金额 > 0 then 金额 else 0 end) as 本月新增,
    sum(case when 日期 >= @入账日期Ge and 日期 <= @入账日期Le and 金额 < 0 then -金额 else 0 end) as 本月减少 ,
sum(case when 日期 <= @入账日期Le then isnull(金额,0) else 0 end) as 月末值
from 视图查询_押金 
    group by 相关人,类型
	
)







CREATE function [dbo].[函数更新_车辆管理_费用承担](@id uniqueidentifier)
returns table
return
(
	select isnull(sum(case when 费用归属 = 4 and (对账单 is not null or 凭证费用明细 is not null) then 金额 else 0 end),0) as 对外已确认,
		   isnull(sum(case when 费用归属 = 4 and 对账单 is null and 凭证费用明细 is null then 金额 else 0 end),0) as 对外未确认,
		   --车主已确认 车辆承担
		   isnull(sum(case when 费用归属 = 2 and (对账单 is not null or 凭证费用明细 is not null) then 金额 else 0 end),0) + 
		   isnull(sum(case when 车辆承担 = 1 and (对账单 is not null or 凭证费用明细 is not null) then 金额 else 0 end),0) as 车主已确认,
		   --车主未确认 车辆承担
		   isnull(sum(case when 费用归属 = 2 and 对账单 is null and 凭证费用明细 is null then 金额 else 0 end),0) + 
		   isnull(sum(case when 车辆承担 = 1 and 对账单 is null and 凭证费用明细 is null then 金额 else 0 end),0) as 车主未确认,
		   
		   isnull(sum(case when 费用归属 = 3 and (对账单 is not null or 凭证费用明细 is not null) then 金额 else 0 end),0) as 驾驶员已确认,
		   isnull(sum(case when 费用归属 = 3 and 对账单 is null and 凭证费用明细 is null then 金额 else 0 end),0) as 驾驶员未确认,
		   isnull(sum(case when 费用归属 = 1 then 金额 else 0 end),0) as 车队承担
	from 财务_费用 as a inner join 财务_费用实体 as b on a.费用实体 = b.id
	where 费用实体 = @id and 费用项 in (select 编号 from 参数备案_费用项 where 现有费用实体类型 like '%' + Convert(varchar(50),b.费用实体类型) + '%')

)


CREATE function [dbo].[函数更新_库存加油_警示状态](@id uniqueidentifier)
returns @tb table(警示状态 nvarchar(100))
as
begin
	declare @count int,@state nvarchar(100) 
	set @state = ''
--未生成费用
	if (select 买卖标志 from 车辆_库存加油 where id = @id) != 1
	begin
		select @count = count(id) from 财务_费用 where 费用实体 = @id
		if @count < 1
		begin
			set @state = @state + '21,'
		end
	end
	
	insert into @tb values (@state)
	return 
end


CREATE function [dbo].[函数更新_车辆机油_警示状态](@id uniqueidentifier)
returns @tb table(警示状态 nvarchar(100))
as
begin
	declare @count int,@state nvarchar(100) 
	set @state = ''
--未生成费用
	if (select 买卖标志 from 车辆_机油 where id = @id) != 1
	begin
		select @count = count(id) from 财务_费用 where 费用实体 = @id
		if @count < 1
		begin
			set @state = @state + '21,'
		end
	end
	
	insert into @tb values (@state)
	return 
end


create function [dbo].[函数更新_车辆加油_警示状态](@id uniqueidentifier)
returns @tb table(警示状态 nvarchar(100))
as
begin
	declare @count int,@state nvarchar(100) 
	set @state = ''
--未生成费用
	select @count = count(id) from 财务_费用 where 费用实体 = @id
	if @count < 1
	begin
		set @state = @state + '11,'
	end
	
	insert into @tb values (@state)
	return 
end


CREATE function [dbo].[函数更新_车辆轮胎_警示状态](@id uniqueidentifier)
returns @tb table(警示状态 nvarchar(100))
as
begin
	declare @count int,@state nvarchar(100) 
	set @state = ''
--未生成费用
	if (select 日期 from 车辆_车辆费用实体 where id = @id) is not null
	begin
		select @count = count(id) from 财务_费用 where 费用实体 = @id 
		if @count < 1
		begin
			set @state = @state + '1,'
		end
	end

--使用未到期
	select @count = datediff(month,购入时间,返回时间) from 车辆_轮胎 as a inner join
	财务_费用实体 as b on a.id = b.id and b.submitted = 0
	where a.id = @id
	if @count < 10
	begin
		set @state = @state + '2,'
	end
	
--使用超期
	if @count > 10
	begin
		set @state = @state + '3,'
	end
	
--已卖车辆
	select @count = count(id) from 参数备案_车辆 where IsActive = 0 and id = 
	(select 车辆 from 车辆_轮胎 as a inner join 财务_费用实体 as b on a.id = b.id and b.submitted = 0 inner join 车辆_车辆费用实体 as c on a.id = c.id
	where a.id = @id)		
	if @count > 0
	begin
		set @state = @state + '4,'
	end
	
--亏损
	select @count = (case when c.金额 > (select sum(金额) from 财务_费用 where 费用实体 = a.id and 费用项 = 382 and 费用归属 = 2) then 1 else 0 end) 
	from 车辆_轮胎 as a inner join 财务_费用实体 as b on a.id = b.id and b.submitted = 0 inner join 车辆_车辆费用实体 as c on a.id = c.id
	where a.id = @id
	if @count = 1
	begin
		set @state = @state + '5,'
	end
	
--已结束未入账	
	select @count = count(a.id) from 车辆_轮胎 as a inner join 财务_费用实体 as b on a.id = b.id and b.submitted = 0 
	where a.id = @id and 返回时间 is not null
	if @count > 0 
	begin
		set @state = @state + '6,'
	end

--未填全	
	select @count = count(id) from 车辆_轮胎
	where id = @id and 资产类别 = 1 and (资产类别 IS NULL OR 购入时间 IS NULL OR 名称 IS NULL OR 型号 IS NULL OR 轮胎号 IS NULL)
	if @count > 0 
	begin
		set @state = @state + '7,'
	end
	
	insert into @tb values (@state)
	return 
end




create function [dbo].[函数更新_车辆其他_警示状态](@id uniqueidentifier)
returns @tb table(警示状态 nvarchar(100))
as
begin
	declare @count int,@state nvarchar(100) 
	set @state = ''
--未生成费用
	select @count = count(id) from 财务_费用 where 费用实体 = @id
	if @count < 1
	begin
		set @state = @state + '61,'
	end
	
	insert into @tb values (@state)
	return 
end

CREATE function [dbo].[函数更新_车辆事故_警示状态](@id uniqueidentifier)
returns @tb table(警示状态 nvarchar(100))
as
begin
	declare @count int,@state nvarchar(100) 
	set @state = ''
--未生成费用
	select @count = count(id) from 财务_费用 where 费用实体 = @id
	if @count < 1
	begin
		set @state = @state + '41,'
	end
	
--保险公司未赔偿
	select @count = count(id) from 财务_费用 where 费用实体 = @id and 费用归属 = 4 and 收付标志 = 1
	if @count < 1
	begin
		set @state = @state + '42,'
	end	
	
--车主未赔偿
	select @count = count(id) from 财务_费用 where 费用实体 = @id and 费用归属 = 2 and 收付标志 = 1
	if @count < 1
	begin
		set @state = @state + '43,'
	end	
	
--驾驶员未赔偿
	select @count = count(id) from 财务_费用 where 费用实体 = @id and 费用归属 = 3 and 收付标志 = 1
	if @count < 1
	begin
		set @state = @state + '44,'
	end	
	
--亏损
	select @count = count(id) from 财务_费用 where 费用实体 = @id and 费用归属 = 3 and 收付标志 = 1
	if @count < 1
	begin
		set @state = @state + '45,'
	end	
	
	insert into @tb values (@state)
	return 
end

CREATE function [dbo].[函数更新_车辆维修_警示状态](@id uniqueidentifier)
returns @tb table(警示状态 nvarchar(100))
as
begin
	declare @count int,@state nvarchar(100) 
	set @state = ''
--未生成费用
	select @count = count(id) from 财务_费用 where 费用实体 = @id
	if @count < 1
	begin
		set @state = @state + '31,'
	end
	
--超过一个月	
	select @count = datediff(day,上次日期,getdate())
	from 车辆_维修 as a inner join 财务_费用实体 as b on a.id = b.id
	where a.Id = @id and b.submitted = 0 and a.修理类型 = 1
	if @count > 30
	begin
		set @state = @state + '32,'
	end	
	
	insert into @tb values (@state)
	return 
end

CREATE function [dbo].[函数更新_车辆资产_警示状态](@id uniqueidentifier)
returns @tb table(警示状态 nvarchar(100))
as
begin
	declare @count int,@state nvarchar(100) 
	set @state = ''
--未生成费用
	select @count = count(id) from 财务_费用 where 费用实体 = @id
	if @count = 0
	begin
		set @state = @state + '51,'
	end
	
--超过一个月	
	select @count = datediff(day,上次折旧日期,getdate())
	from 车辆_资产 as a inner join 财务_费用实体 as b on a.id = b.id
	where a.Id = @id and b.submitted = 0
	if @count > 30
	begin
		set @state = @state + '52,'
	end
	
--剩余折旧不足月折旧额	
	select @count = case when c.金额 > a.剩余折旧 then 1 else 0 end 
	from 车辆_资产 as a inner join 财务_费用实体 as b on a.id = b.id inner join 车辆_车辆费用实体 as c on a.id = c.id 
	where a.Id = @id and b.submitted = 0	
	if @count = 1
	begin
		set @state = @state + '53,'
	end
	
--折旧完全但剩余金额不为零
	set @count = null	
	select @count = 剩余折旧 from 车辆_资产 as a inner join 财务_费用实体 as b on a.id = b.id
	where a.Id = @id and b.submitted = 1
	if @count > 0
	begin
		set @state = @state + '54,'
	end
	
	insert into @tb values (@state)
	return 
end




CREATE function [dbo].[函数更新_固定资产_警示状态](@id uniqueidentifier)
returns @tb table(警示状态 nvarchar(100))
as
begin
	declare @count int,@state nvarchar(100) 
	set @state = ''
--未生成费用
	select @count = count(id) from 财务_费用 where 费用实体 = @id
	if @count = 0
	begin
		set @state = @state + '51,'
	end
	
--超过一个月	
	select @count = datediff(day,上次折旧日期,getdate())
	from 财务_固定资产 as a inner join 财务_费用实体 as b on a.id = b.id
	where a.Id = @id and b.submitted = 0
	if @count > 30
	begin
		set @state = @state + '52,'
	end
	
--剩余折旧不足月折旧额	
	select @count = case when 月折旧额 > 剩余折旧 then 1 else 0 end 
	from 财务_固定资产 as a inner join 财务_费用实体 as b on a.id = b.id
	where a.Id = @id and b.submitted = 0	
	if @count = 1
	begin
		set @state = @state + '53,'
	end
	
--折旧完全但剩余金额不为零
	set @count = null	
	select @count = 剩余折旧 from 财务_固定资产 as a inner join 财务_费用实体 as b on a.id = b.id
	where a.Id = @id and b.submitted = 1
	if @count > 0
	begin
		set @state = @state + '54,'
	end
	
	insert into @tb values (@state)
	return 
end

create function [dbo].[函数更新_固定资产](@id uniqueidentifier)
returns table
return
(
	select isnull(sum(case when 费用项 = 387 and (对账单 is not null or 凭证费用明细 is not null) then 金额 else 0 end),0) as 对外已确认,
		   isnull(sum(case when 费用项 = 387 and 对账单 is null and 凭证费用明细 is null then 金额 else 0 end),0) as 对外未确认,
		   isnull(sum(case when 费用项 <> 387 and (对账单 is not null or 凭证费用明细 is not null) then 金额 else 0 end),0) as 其他已确认,
		   isnull(sum(case when 费用项 <> 387 and 对账单 is null and 凭证费用明细 is null then 金额 else 0 end),0) as 其他未确认
	from 财务_费用 as a inner join 财务_费用实体 as b on a.费用实体 = b.id
	where 费用实体 = @id and 费用项 in (select 编号 from 参数备案_费用项 where 现有费用实体类型 like '%' + Convert(varchar(50),b.费用实体类型) + '%')

)

CREATE function [dbo].[函数更新_财务_费用信息](@id uniqueidentifier)
returns table
return
(
	select isnull(sum(case when 费用归属 = 4 and (对账单 is not null or 凭证费用明细 is not null) then 金额 else 0 end),0) as 对外已确认,
		   isnull(sum(case when 费用归属 = 4 and 对账单 is null and 凭证费用明细 is null then 金额 else 0 end),0) as 对外未确认,
		   --车主已确认 车辆承担
		   isnull(sum(case when 费用归属 = 2 and (对账单 is not null or 凭证费用明细 is not null) then 金额 else 0 end),0) + 
		   isnull(sum(case when 车辆承担 = 1 and (对账单 is not null or 凭证费用明细 is not null) then 金额 else 0 end),0) as 车主已确认,
		   --车主未确认 车辆承担
		   isnull(sum(case when 费用归属 = 2 and 对账单 is null and 凭证费用明细 is null then 金额 else 0 end),0) + 
		   isnull(sum(case when 车辆承担 = 1 and 对账单 is null and 凭证费用明细 is null then 金额 else 0 end),0) as 车主未确认,
		   
		   isnull(sum(case when 费用归属 = 3 and (对账单 is not null or 凭证费用明细 is not null) then 金额 else 0 end),0) as 驾驶员已确认,
		   isnull(sum(case when 费用归属 = 3 and 对账单 is null and 凭证费用明细 is null then 金额 else 0 end),0) as 驾驶员未确认,
		   isnull(sum(case when 收付标志 = 1 and 车辆承担 = 0 then 金额 when 收付标志 = 2 and 车辆承担 = 0 then -金额 else 0 end),0) as 车队承担
	from 财务_费用 
	where 费用信息 = @id 

)




CREATE function [dbo].[函数查询月报表_费用明细](@入账日期Ge datetime = '2005-1-1', @入账日期Le datetime = '2020-12-31')
returns table
as
return
(
		SELECT @入账日期Ge as 入账日期始,@入账日期Le as 入账日期止,大类,小类,类别,
			isnull(SUM(case when 入账日期 < @入账日期Ge then 增加 else 0 end),0) - isnull(SUM(case when 入账日期 < @入账日期Ge then 减少 else 0 end),0) AS 期初数,
			isnull(SUM(case when 入账日期 between @入账日期Ge and @入账日期Le then 增加 else 0 end),0) - isnull(SUM(case when 入账日期 between @入账日期Ge and @入账日期Le then 减少 else 0 end),0) AS 本月,
			isnull(SUM(case when 入账日期 < @入账日期Ge then 增加 else 0 end),0) - isnull(SUM(case when 入账日期 < @入账日期Ge then 减少 else 0 end),0) + 
			(isnull(SUM(case when 入账日期 between @入账日期Ge and @入账日期Le then 增加 else 0 end),0) - isnull(SUM(case when 入账日期 between @入账日期Ge and @入账日期Le then 减少 else 0 end),0)) AS 期末数
 	FROM 视图查询月报表_费用明细
 	GROUP BY 大类,小类,类别
)




CREATE function [dbo].[函数更新_业务备案_车辆产值_委托人已对账](@id varchar(50))
returns table
as
return
(
	select (case when count(费用信息) = 0 then 'False' else 'True' end) as 委托人已对账 
	from 视图查询_费用明细_费用类型_业务 
	where 收付标志 = 1 AND 费用实体 = @id AND 对账单号 IS NOT NULL AND 费用归属=1

)



CREATE function [dbo].[函数更新_车辆保险_警示状态](@id uniqueidentifier)
returns @tb table(警示状态 nvarchar(100))
as
begin
	declare @count int,@state nvarchar(100) 
	set @state = ''
--未生成费用
	select @count = count(id) from 财务_费用 where 费用实体 = @id
	if @count = 0
	begin
		set @state = @state + '71,'
	end
	
--超过一个月	
	select @count = datediff(day,上次折旧日期,getdate())
	from 车辆_保险 as a inner join 财务_费用实体 as b on a.id = b.id
	where a.Id = @id and b.submitted = 0
	if @count > 30
	begin
		set @state = @state + '72,'
	end
	
--剩余折旧不足月折旧额	
	select @count = case when c.金额 > a.剩余折旧 then 1 else 0 end 
	from 车辆_保险 as a inner join 财务_费用实体 as b on a.id = b.id inner join 车辆_车辆费用实体 as c on a.id = c.id
	where a.Id = @id and b.submitted = 0	
	if @count = 1
	begin
		set @state = @state + '73,'
	end
	
--折旧完全但剩余金额不为零
	set @count = null	
	select @count = 剩余折旧 from 车辆_保险 as a inner join 财务_费用实体 as b on a.id = b.id
	where a.Id = @id and b.submitted = 1
	if @count > 0
	begin
		set @state = @state + '74,'
	end
	
	insert into @tb values (@state)
	return 
end




CREATE function [dbo].[函数更新_费用信息_警示状态](@id uniqueidentifier)
returns @tb table(警示状态 nvarchar(100))
as
begin
	declare @count decimal(19,2),@state nvarchar(20),@fyx int
	set @state = ''
----委托人理论值不一致
--	if (select 委托人理论值 from 财务_费用信息 where id = @id) is not null 
--	begin
--		select @count = 委托人已确认 + 委托人未确认 - 委托人理论值 from 财务_费用信息 where id = @id
--		if @count <> 0
--		begin
--			set @state = @state + '81,'
--		end
--	end
--
----车主理论值不一致
--	if (select 车主理论值 from 财务_费用信息 where id = @id) is not null 
--	begin
--		select @count = 车主已确认 + 车主未确认 - 车主理论值 from 财务_费用信息 where id = @id
--		if @count <> 0
--		begin
--			set @state = @state + '82,'
--		end
--	end
--
----驾驶员理论值不一致
--	if (select 驾驶员理论值 from 财务_费用信息 where id = @id) is not null 
--	begin
--		select @count = 驾驶员已确认 + 驾驶员未确认 - 驾驶员理论值 from 财务_费用信息 where id = @id
--		if @count <> 0
--		begin
--			set @state = @state + '83,'
--		end
--	end
--
----对外理论值不一致
--	if (select 对外理论值 from 财务_费用信息 where id = @id) is not null 
--	begin
--		select @count = 对外已确认 + 对外未确认 - 对外理论值 from 财务_费用信息 where id = @id
--		if @count <> 0
--		begin
--			set @state = @state + '84,'
--		end
--	end
--	
--收付不一致
	select @count = 车队承担,@fyx = 费用项 from 财务_费用信息 where id = @id	
	if (@count < 0 and @fyx in (102,103,135)) or (@count <> 0 and @fyx not in (102,103,160,161,162,165,167,335,135))
	begin
		set @state = @state + '85,'
	end
	
	insert into @tb values (@state)
	return 
end





create function [dbo].[函数更新_财务_理论值](@id uniqueidentifier, @fyx int)
returns table
as
return
(
	select sum(case when 费用归属 = 1 and 收付标志 = 1 then 金额 else null end) as 委托人理论值,
			sum(case when 费用归属 = 2 and 收付标志 = 1 then 金额 else null end) as 车主理论值,
			sum(case when 费用归属 = 3 and 收付标志 = 2 then 金额 else null end) as 驾驶员理论值,
			sum(case when 费用归属 = 4 and 收付标志 = 2 then 金额 else null end) as 对外理论值			
	from 财务_业务费用理论值
	where 费用实体 = @id and 费用项 = @fyx
)


CREATE proc [dbo].[过程更新_业务财务_对账单费用查验]
as
begin
	--90 = 未备案	    91 = 提单号不合理	92 = 箱号不合理	93 = 金额不同	94 = 已对账已凭证
    --95 = 未对账	    96 = 未登记		97 = 未排车		98 = 费用不完整	99 = 多条费用项
    update Temp_对账单费用查验 set 任务 = null,状态 = ''
    
	update Temp_对账单费用查验 set 任务 = B.Id, 车辆产值 = B.车辆产值
	FROM Temp_对账单费用查验 as A inner join 
	业务备案_任务 as B on A.提单号 = B.提单号 and A.箱号 = B.箱号
	
	update Temp_对账单费用查验 set 状态 = '90,' where 任务 is null
	
	update Temp_对账单费用查验 set 状态 = '91,'
	FROM Temp_对账单费用查验 as A inner join 
	业务备案_任务 as B on A.提单号 <> B.提单号 and A.箱号 = B.箱号
	where A.任务 is null
	
	update Temp_对账单费用查验 set 状态 = '92,'
	FROM Temp_对账单费用查验 as A inner join 
	业务备案_任务 as B on A.提单号 = B.提单号 and A.箱号 <> B.箱号
	where A.任务 is null
	
	update Temp_对账单费用查验 set 状态 = '97,' where 任务 is not null and 车辆产值 is null
	
	update Temp_对账单费用查验 set 状态 = case when (select count(id) from 财务_费用 
													where 任务 = a.任务 and 相关人 = a.相关人 and 费用项 = a.费用项) = 0 then '96,' 
											when (select count(id) from 财务_费用 
													where 任务 = a.任务 and 费用项 = a.费用项 and 相关人 = a.相关人 and 金额 = a.金额) > 1 then '99,'
											else 状态 end
	from Temp_对账单费用查验 as a 
	where a.任务 is not null and a.费用项 is not null and a.相关人 is not null and 状态 = ''
		
	update Temp_对账单费用查验 set 状态 = case when a.金额 <> b.金额 then '93,'
											 when b.对账单 is not null or b.凭证费用明细 is not null then '94,' 
											 when b.对账单 is null and 凭证费用明细 is null then '95,'
											 else 状态 end
	from Temp_对账单费用查验 as a inner join 财务_费用 as b 
	on a.任务 = b.任务 and a.费用项 = b.费用项 and a.相关人 = b.相关人
	where a.任务 is not null and a.费用项 is not null and a.相关人 is not null and 状态 = ''	
	
	update Temp_对账单费用查验 set 状态 = '98,' where 相关人 is null or 提单号 is null or 费用项 is null or 金额 is null
end

CREATE proc [dbo].[数据整理_支出表]
as
begin
--任务没备案的55条
--select * from Temp_支出表 where 任务id is null

	update Temp_支出表 set 任务类别编号 = case when 任务类别 = '拆' then 1 
												when 任务类别 = '装' then 2
												when 任务类别 = '驳' then 4
												else 3 end

	update Temp_支出表 set 箱号 = 'TTNU4492294' where 箱号 = 'TGHU4492294'
	update Temp_支出表 set 箱号 = 'TEXU5535832' where 箱号 = 'TEXI5535832'
end


CREATE proc [dbo].[过程更新_车辆维修_警示状态]
as
begin
	update 车辆_车辆费用实体 set 对外已确认 = (select 对外已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 对外未确认 = (select 对外未确认 from 函数更新_车辆管理_费用承担(a.id)), 
						 车主已确认 = (select 车主已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车主未确认 = (select 车主未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员已确认 = (select 驾驶员已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员未确认 = (select 驾驶员未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车队承担 = (select 车队承担 from 函数更新_车辆管理_费用承担(a.id)),
						 更新时间 = getdate()
	from 车辆_车辆费用实体 as a inner join 车辆_维修 as b on a.id = b.id
	
	update 车辆_维修 set 上次日期 = (select max(关账日期) from 财务_对账单 where id in (select 对账单 from 财务_费用 where 费用实体 = a.id))
	from 车辆_维修 as a
	
	update 车辆_车辆费用实体 set 警示状态 = (select 警示状态 from 函数更新_车辆维修_警示状态(a.id))
	from 车辆_车辆费用实体 as a inner join 车辆_维修 as b on a.id = b.id

      update 车辆_车辆费用实体 set 简介 = (case when b.修理类型 = 1 then '包月' else b.项目 end)
	from 车辆_车辆费用实体 as a inner join 车辆_维修 as b on a.id = b.id
end



CREATE proc [dbo].[数据整理_支出表_费用登记]
as
begin
	--对外  路桥费
	update 财务_费用 set 相关人 = 
	(select b.驾驶员 from 业务备案_任务 as a 
	inner join 业务备案_车辆产值 as b on a.车辆产值 =b.id where a.id=g.任务),
	金额 = (select 过路费 from Temp_支出表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=211 and g.费用归属 = 4

	update 财务_费用 set 收付标志=2
	where 费用项=211 and 费用归属 = 4
		
	--车主  路桥费
	update 财务_费用 set 相关人 = 
	(select b.承运人 from 业务备案_任务 as a 
	inner join 业务备案_车辆产值 as b on a.车辆产值 =b.id where a.id=g.任务),
	金额 = (select 过路费 from Temp_支出表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=211 and g.费用归属 = 2
	
	--对外  吊机费
	update 财务_费用 set 相关人 = 
	(select b.驾驶员 from 业务备案_任务 as a 
	inner join 业务备案_车辆产值 as b on a.车辆产值 =b.id where a.id=g.任务),
	金额 = (select 吊机费 from Temp_支出表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=111 and g.费用归属 = 4

	update 财务_费用 set 收付标志=2
	where 费用项=111 and 费用归属 = 4
		
	--车主  吊机费
	update 财务_费用 set 相关人 = 
	(select b.承运人 from 业务备案_任务 as a 
	inner join 业务备案_车辆产值 as b on a.车辆产值 =b.id where a.id=g.任务),
	金额 = (select 吊机费 from Temp_支出表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=111 and g.费用归属 = 2
	
	--对外  其他费
	update 财务_费用 set 相关人 = 
	(select b.驾驶员 from 业务备案_任务 as a 
	inner join 业务备案_车辆产值 as b on a.车辆产值 =b.id where a.id=g.任务),
	金额 = (select 其他 from Temp_支出表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=219 and g.费用归属 = 4

	update 财务_费用 set 收付标志=2
	where 费用项=219 and 费用归属 = 4
		
	--车主  其他费
	update 财务_费用 set 相关人 = 
	(select b.承运人 from 业务备案_任务 as a 
	inner join 业务备案_车辆产值 as b on a.车辆产值 =b.id where a.id=g.任务),
	金额 = (select 其他 from Temp_支出表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=219 and g.费用归属 = 2
	
	--备注  凭证号
	update 财务_费用 set 备注 = (select 凭证号 from Temp_支出表 where 任务id=g.任务)
	from 财务_费用 as g
	where g.费用项 in (111,211,219) and g.费用归属 = 4
end
CREATE proc [dbo].[过程更新_车辆资产_警示状态]
as
begin
	update 车辆_车辆费用实体 set 对外已确认 = (select 对外已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 对外未确认 = (select 对外未确认 from 函数更新_车辆管理_费用承担(a.id)), 
						 车主已确认 = (select 车主已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车主未确认 = (select 车主未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员已确认 = (select 驾驶员已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员未确认 = (select 驾驶员未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车队承担 = (select 车队承担 from 函数更新_车辆管理_费用承担(a.id)),
						 更新时间 = getdate()
	from 车辆_车辆费用实体 as a inner join 车辆_资产 as b on a.id = b.id
	
	update 车辆_资产 set 剩余折旧 = (select a.购入金额+a.购置税 - isnull(sum(金额),0) from 财务_费用 where 费用实体 = a.id and 费用归属 = 4 and 相关人 = '900031'),
						 上次折旧日期 = (select max(关账日期) from 财务_对账单 where id in (select 对账单 from 财务_费用 where 费用实体 = a.id AND 相关人 = '900031'))
	from 车辆_资产 as a
	
	update 车辆_车辆费用实体 set 警示状态 = (select 警示状态 from 函数更新_车辆资产_警示状态(a.id))
	from 车辆_车辆费用实体 as a inner join 车辆_资产 as b on a.id = b.id
end



create proc [dbo].[过程更新_查询_现金日记帐_行数]
as
begin
delete 查询_现金日记帐_行数
insert into 查询_现金日记帐_行数 (金额,存取标志,ID,币制,源,日期,相关号码,摘要,当前行数)
(select * from 视图查询_现金日记帐_行数)
end



create proc [dbo].[过程更新_查询_银行日记帐_行数]
as
begin
delete 查询_银行日记帐_行数
insert into 查询_银行日记帐_行数 (金额,存取标志,ID,银行账户,源,日期,相关号码,摘要,当前行数)
(select * from 视图查询_银行日记帐_行数)
end




CREATE proc [dbo].[过程更新_固定资产]
as
begin
	update 财务_固定资产 set 对外已确认 = (select 对外已确认 from 函数更新_固定资产(a.id)),
						 对外未确认 = (select 对外未确认 from 函数更新_固定资产(a.id)), 
						 其他已确认 = (select 其他已确认 from 函数更新_固定资产(a.id)),
						 其他未确认 = (select 其他未确认 from 函数更新_固定资产(a.id)),
						 更新时间 = getdate(),
						  剩余折旧 = (select a.购入金额 - isnull(sum(金额),0) from 财务_费用 where 费用实体 = a.id and 相关人 = '900031'),
						 上次折旧日期 = (select max(关账日期) from 财务_对账单 where id in (select 对账单 from 财务_费用 where 费用实体 = a.id AND 相关人 = '900031'))
	from 财务_固定资产 as a

	update 财务_固定资产 set 警示状态 = (select 警示状态 from 函数更新_固定资产_警示状态(a.id))
	from 财务_固定资产 as a
end



CREATE proc [dbo].[启动关闭远程查询组件](@input int = 1)
as
begin
--参数0 = 关闭, 1 = 启动, 其他参数无效
	if @input = 1
	begin
		--启用Ad Hoc Distributed Queries
		exec sp_configure 'show advanced options',1
		reconfigure
		exec sp_configure 'Ad Hoc Distributed Queries',1
		reconfigure
	end
	else if @input = 0
	begin
		--关闭Ad Hoc Distributed Queries
		exec sp_configure 'Ad Hoc Distributed Queries',0
		reconfigure
		exec sp_configure 'show advanced options',0
		reconfigure 
	end
	else
	begin
		print '参数无效。0 = 关闭, 1 = 启动'
	end
end

CREATE proc [dbo].[过程更新_车辆机油_警示状态]
as
begin
	update 车辆_车辆费用实体 set 对外已确认 = (select 对外已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 对外未确认 = (select 对外未确认 from 函数更新_车辆管理_费用承担(a.id)), 
						 车主已确认 = (select 车主已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车主未确认 = (select 车主未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员已确认 = (select 驾驶员已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员未确认 = (select 驾驶员未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车队承担 = (select 车队承担 from 函数更新_车辆管理_费用承担(a.id)),
						 更新时间 = getdate()
	from 车辆_车辆费用实体 as a inner join 车辆_机油 as b on a.id = b.id
	
	update 车辆_车辆费用实体 set 警示状态 = (select 警示状态 from 函数更新_车辆机油_警示状态(a.id))
	from 车辆_车辆费用实体 as a inner join 车辆_机油 as b on a.id = b.id

update 车辆_车辆费用实体 set 简介 = (case when b.机油类别 = 2 then '防冻液' else '机油' end)
	from 车辆_车辆费用实体 as a inner join 车辆_机油 as b on a.id = b.id
end



CREATE proc [dbo].[数据整理_产值表]
as
begin
	--delete from Temp_产值表
	--select * from Temp_产值表

	update Temp_产值表 set 箱量 = dbo.Get_StrArrayStrOfIndex(a.货代自编号,'/',1)
	from Temp_产值表 as a
	where 货代自编号 in (select 货代自编号 from Temp_产值表 where 货代自编号 like '%/%')

	update Temp_产值表 set 任务关系 = '套箱' 
	where 任务类别 = '套'

	update Temp_产值表 set 任务关系 = '对箱' 
	where 箱型 = '20*2'

	update Temp_产值表 set 箱型 = '20' 
	where 箱型 = '20*2'

	update Temp_产值表 set 箱号 = replace(箱号,' ',',')
	where 箱号 like '% %'

	Insert into Temp_产值表 (日期,车辆类别,车号,驾驶员,指运地,任务类别编号,任务类别,货代自编号,船名航次,提单号,箱号,箱型,产值,应付,扣税,车队收,产值备注,入库单号,箱量,任务关系) 
		select 日期,车辆类别,车号,驾驶员,指运地,任务类别编号,任务类别,货代自编号,船名航次,提单号,dbo.Get_StrArrayStrOfIndex(a.箱号,',,',2),箱型,产值,应付,扣税,车队收,产值备注,入库单号,箱量,任务关系 from Temp_产值表 as a where 箱号 like '%,%'

	update Temp_产值表 set 箱号 = dbo.Get_StrArrayStrOfIndex(a.箱号,',',1)
	from Temp_产值表 as a
	where 箱号 like '%,%'

	update Temp_产值表 set 驾驶员 = 车号,车号 = 驾驶员
	where 车辆类别 in (3,4)
	
	update Temp_产值表 set 车号 = null
	where 车号 in ('衣成德','杰华')
	
	update Temp_产值表 set 任务类别编号 = case when 任务类别 = '拆' then 1 
												when 任务类别 = '装' then 2
												when 任务类别 = '驳' then 4
												else 3 end
												
	update Temp_产值表 set 箱号 = 'GLDU4051368' where 箱号 = 'GATU4051368' and 任务类别='拆'
	update Temp_产值表 set 箱号 = 'TTNU4492294' where 箱号 = 'TGHU4492294' and 任务类别='拆'
	update Temp_产值表 set 箱号 = 'TTNU9480296' where 箱号 = 'TTNU9480269' and 任务类别='拆'
	update Temp_产值表 set 箱号 = 'ECMU9373527' where 箱号 = 'ECMU9373257' and 任务类别='拆'
	update Temp_产值表 set 箱号 = 'ECMU9214090' where 箱号 = 'ECMU9124090' and 任务类别='拆'
	update Temp_产值表 set 箱号 = 'INKU6090699' where 箱号 = 'INKU6090669' and 任务类别='拆'
	update Temp_产值表 set 箱号 = 'UGMU8162667' where 箱号 = 'ECMU8162667' and 任务类别='拆'
	update Temp_产值表 set 箱号 = 'HMCU9071617' where 箱号 = 'EMCU9071617' and 任务类别='拆'
	update Temp_产值表 set 箱号 = 'POCU1193267' where 箱号 = 'PONU1193267' and 任务类别='拆'
	update Temp_产值表 set 箱号 = 'EMCU1413515' where 箱号 = 'ECMU1413515' and 任务类别='拆'
	update Temp_产值表 set 箱号 = 'MRKU0459605' where 箱号 = 'MRXU0459605' and 任务类别='拆'
	update Temp_产值表 set 箱号 = 'TCKU9493300' where 箱号 = 'TCNU9493300' and 任务类别='拆'
	update Temp_产值表 set 箱号 = 'CCLU6265040' where 箱号 = 'CCLU7519940' and 任务类别='倒'
	update Temp_产值表 set 箱号 = 'IRSU5048837' where 箱号 = 'ZRSU5048837' and 任务类别='拆'
	update Temp_产值表 set 箱号 = 'TEXU5535832' where 箱号 = 'TEXI5535832' 
	update Temp_产值表 set 箱号 = 'MRKU0221725' where 箱号 = 'MSKU0221725' 
	update Temp_产值表 set 箱号 = 'IRSU5062898' where 箱号 = 'ZRSU5062898'
	update Temp_产值表 set 箱号 = 'XXXXXXXXXXX' where 箱号 = '' and 任务类别='驳'
	--修洗箱费  应收货代 and 应付陈祖奎   2个箱号
	--update Temp_修洗箱费 set 箱号 = 'CLHU8727976' where 箱号 = 'CLHU8732725' and 任务类别='拆'									
	--update Temp_修洗箱费 set 箱号 = 'EISU9878846' where 箱号 = 'EISU9876846' and 任务类别='拆'
	
	update Temp_产值表 set 驾驶员 = case when 驾驶员 = '小蒉' then '蒉红波'
										 when 驾驶员 = '邢老板' then '刑树强'
										 when 驾驶员 = '王秋生' then '王秋升'
										 when 驾驶员 = '杰华' then '杰华物流' end
	where 驾驶员 in ('小蒉','邢老板','王秋生','杰华')
	
	update Temp_产值表 set 车辆类别 = 3 where 车号 = '30956'

end

CREATE proc [dbo].[过程更新_车辆加油_警示状态]
as
begin
	update 车辆_车辆费用实体 set 对外已确认 = (select 对外已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 对外未确认 = (select 对外未确认 from 函数更新_车辆管理_费用承担(a.id)), 
						 车主已确认 = (select 车主已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车主未确认 = (select 车主未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员已确认 = (select 驾驶员已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员未确认 = (select 驾驶员未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车队承担 = (select 车队承担 from 函数更新_车辆管理_费用承担(a.id)),
						 更新时间 = getdate()
	from 车辆_车辆费用实体 as a inner join 车辆_加油 as b on a.id = b.id
	
	update 车辆_车辆费用实体 set 警示状态 = (select 警示状态 from 函数更新_车辆加油_警示状态(a.id))
	from 车辆_车辆费用实体 as a inner join 车辆_加油 as b on a.id = b.id
end



CREATE proc [dbo].[过程更新_业务备案_任务]
as
begin
	update 业务备案_任务 set 回货箱号 = 
	(select top 1 箱号 from 业务备案_任务
	where 车辆产值 = a.车辆产值 and 任务类别 in (1,2)) 
	from
	业务备案_任务 as a
	where 回货箱号 is null and 车辆产值 is not null and 任务类别 = 3
	
	update 业务备案_任务 set 箱型 = 
	(select top 1 箱型 from 业务备案_任务
	where 车辆产值 = a.车辆产值 and 任务类别 in (1,2)) 
	from
	业务备案_任务 as a
	where 箱型 is null and 车辆产值 is not null and 任务类别 = 3
end


CREATE proc [dbo].[过程更新_车辆保险_警示状态]
as
begin
	update 车辆_车辆费用实体 set 对外已确认 = (select 对外已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 对外未确认 = (select 对外未确认 from 函数更新_车辆管理_费用承担(a.id)), 
						 车主已确认 = (select 车主已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车主未确认 = (select 车主未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员已确认 = (select 驾驶员已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员未确认 = (select 驾驶员未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车队承担 = (select 车队承担 from 函数更新_车辆管理_费用承担(a.id)),
						 更新时间 = getdate()
	from 车辆_车辆费用实体 as a inner join 车辆_保险 as b on a.id = b.id
	
	update 车辆_保险 set 剩余折旧 = (select a.购入金额 - isnull(sum(金额),0) from 财务_费用 where 费用实体 = a.id and 费用归属 = 4 and 相关人 = '900031'),
						 上次折旧日期 = (select max(关账日期) from 财务_对账单 where id in (select 对账单 from 财务_费用 where 费用实体 = a.id AND 相关人 = '900031'))
	from 车辆_保险 as a
	
	update 车辆_车辆费用实体 set 警示状态 = (select 警示状态 from 函数更新_车辆保险_警示状态(a.id))
	from 车辆_车辆费用实体 as a inner join 车辆_保险 as b on a.id = b.id
	
end



create proc [dbo].[数据整理_产值表_费用登记]
as
begin
	--委托人  运费
	update 财务_费用 set 相关人 = 
	(select 委托人 from 业务备案_任务 where id=g.任务),
	金额 = (select 产值 from Temp_产值表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=102 and g.费用归属 = 1

	--承运人  运费
	update 财务_费用 set 相关人 = 
	(select b.承运人 from 业务备案_任务 as a 
	inner join 业务备案_车辆产值 as b on a.车辆产值 =b.id where a.id=g.任务),
	金额 = (select 应付 from Temp_产值表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=102 and g.费用归属 = 2

	update 财务_费用 set 收付标志=2
	where 费用项=102 and 费用归属 = 2
	
	--税收
	update 财务_费用 set 金额=
	(select 扣税 from temp_产值表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=335 and g.费用归属 = 4

	update 财务_费用 set 收付标志=2
	where 费用项=335 and 费用归属 = 4
end

CREATE proc [dbo].[过程更新_车辆轮胎_警示状态]
as
begin
	update 车辆_车辆费用实体 set 对外已确认 = (select 对外已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 对外未确认 = (select 对外未确认 from 函数更新_车辆管理_费用承担(a.id)), 
						 车主已确认 = (select 车主已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车主未确认 = (select 车主未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员已确认 = (select 驾驶员已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员未确认 = (select 驾驶员未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车队承担 = (select 车队承担 from 函数更新_车辆管理_费用承担(a.id)),
						 更新时间 = getdate()
	from 车辆_车辆费用实体 as a inner join 车辆_轮胎 as b on a.id = b.id

	update 车辆_车辆费用实体 set 警示状态 = (select 警示状态 from 函数更新_车辆轮胎_警示状态(a.id))
	from 车辆_车辆费用实体 as a inner join 车辆_轮胎 as b on a.id = b.id

	update 车辆_车辆费用实体 set 简介 = (case when b.资产类别 = 1 then '轮胎'+b.轮胎号 else '钢圈' end)
	from 车辆_车辆费用实体 as a inner join 车辆_轮胎 as b on a.id = b.id

end



CREATE proc [dbo].[数据整理_分成表]
as
begin
	update Temp_分成表 set 箱号 = 'TEXU5535832' where 箱号 = 'TEXI5535832' 
	update Temp_分成表 set 箱号 = 'TTNU4492294' where 箱号 = 'TGHU4492294' and 任务类别='拆'
	update Temp_分成表 set 箱号 = 'IRSU5048837' where 箱号 = 'ZRSU5048837' and 任务类别='拆'
	update Temp_分成表 set 箱号 = 'IRSU5062898' where 箱号 = 'ZRSU5062898'
	update Temp_分成表 set 箱号 = 'CCLU6265040' where 箱号 = 'CCLU7519940' and 任务类别='倒'
	
	update Temp_分成表 set 任务类别编号 = case when 任务类别 = '拆' then 1 
												when 任务类别 = '装' then 2
												when 任务类别 = '驳' then 4
												else 3 end
end

CREATE proc [dbo].[过程更新_车辆其他_警示状态]
as
begin
	update 车辆_车辆费用实体 set 对外已确认 = (select 对外已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 对外未确认 = (select 对外未确认 from 函数更新_车辆管理_费用承担(a.id)), 
						 车主已确认 = (select 车主已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车主未确认 = (select 车主未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员已确认 = (select 驾驶员已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员未确认 = (select 驾驶员未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车队承担 = (select 车队承担 from 函数更新_车辆管理_费用承担(a.id)),
						 更新时间 = getdate()
	from 车辆_车辆费用实体 as a inner join 车辆_其他 as b on a.id = b.id
	
	update 车辆_车辆费用实体 set 警示状态 = (select 警示状态 from 函数更新_车辆其他_警示状态(a.id))
	from 车辆_车辆费用实体 as a inner join 车辆_其他 as b on a.id = b.id
end



CREATE proc [dbo].[数据整理_分成表_费用登记]
as
begin
	--驾驶员  工资
	update 财务_费用 set 相关人 = 
	(select b.驾驶员 from 业务备案_任务 as a 
	inner join 业务备案_车辆产值 as b on a.车辆产值 =b.id where a.id=g.任务),
	金额 = (select 工资 from Temp_分成表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=201 and g.费用归属 = 3 

	update 财务_费用 set 收付标志=2
	where 费用项=201 and 费用归属 = 3
	
	--车主  工资
	update 财务_费用 set 相关人 = 
	(select b.承运人 from 业务备案_任务 as a 
	inner join 业务备案_车辆产值 as b on a.车辆产值 =b.id where a.id=g.任务),
	金额 = (select 工资 from Temp_分成表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=201 and g.费用归属 = 2 
	
	--驾驶员  话费补贴
	update 财务_费用 set 相关人 = 
	(select b.驾驶员 from 业务备案_任务 as a 
	inner join 业务备案_车辆产值 as b on a.车辆产值 =b.id where a.id=g.任务),
	金额 = (select 话费补贴 from Temp_分成表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=202 and g.费用归属 = 3 

	update 财务_费用 set 收付标志=2
	where 费用项=202 and 费用归属 = 3
		
	--车主  话费补贴
	update 财务_费用 set 相关人 = 
	(select b.承运人 from 业务备案_任务 as a 
	inner join 业务备案_车辆产值 as b on a.车辆产值 =b.id where a.id=g.任务),
	金额 = (select 话费补贴 from Temp_分成表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=202 and g.费用归属 = 2 
	
	--驾驶员  轮胎补贴
	update 财务_费用 set 相关人 = 
	(select b.驾驶员 from 业务备案_任务 as a 
	inner join 业务备案_车辆产值 as b on a.车辆产值 =b.id where a.id=g.任务),
	金额 = (select 轮胎补贴 from Temp_分成表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=203 and g.费用归属 = 3 

	update 财务_费用 set 收付标志=2
	where 费用项=203 and 费用归属 = 3
		
	--车主  轮胎补贴
	update 财务_费用 set 相关人 = 
	(select b.承运人 from 业务备案_任务 as a 
	inner join 业务备案_车辆产值 as b on a.车辆产值 =b.id where a.id=g.任务),
	金额 = (select 轮胎补贴 from Temp_分成表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=203 and g.费用归属 = 2 
	
	--驾驶员  定耗油
	update 财务_费用 set 相关人 = 
	(select b.驾驶员 from 业务备案_任务 as a 
	inner join 业务备案_车辆产值 as b on a.车辆产值 =b.id where a.id=g.任务),
	数量 = (select 定耗油 from Temp_分成表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=204 and g.费用归属 = 3 and g.备注 = '定耗油' 

	update 财务_费用 set 收付标志=2
	where 费用项=204 and 费用归属 = 3 and 备注 = '定耗油'
		
	--车主  定耗油
	update 财务_费用 set 相关人 = 
	(select b.承运人 from 业务备案_任务 as a 
	inner join 业务备案_车辆产值 as b on a.车辆产值 =b.id where a.id=g.任务),
	数量 = (select 定耗油 from Temp_分成表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=204 and g.费用归属 = 2 and g.备注 = '定耗油' 
	
	--对外  实耗油
	update 财务_费用 set 相关人 = '900026',
	数量 = (select 实耗油 from Temp_分成表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=204 and g.费用归属 = 4 and g.备注 = '实耗油'

	update 财务_费用 set 收付标志=2
	where 费用项=204 and 费用归属 = 4 and 备注 = '实耗油'
		
	--驾驶员  实耗油
	update 财务_费用 set 相关人 = 
	(select b.驾驶员 from 业务备案_任务 as a 
	inner join 业务备案_车辆产值 as b on a.车辆产值 =b.id where a.id=g.任务),
	数量 = (select 实耗油 from Temp_分成表 where 任务id=g.任务),
	updated = getdate()
	from 财务_费用 as g
	where g.费用项=204 and g.费用归属 = 3 and g.备注 = '实耗油' 
	
	update 财务_费用 set 金额 = 数量 * 5.5 where 费用项 = 204 and 备注 in ('定耗油','实耗油')
	update 财务_费用 set 数量 = 金额 * 100 where 费用项 = 203

end

CREATE proc [dbo].[过程更新_车辆事故_警示状态]
as
begin
	update 车辆_车辆费用实体 set 对外已确认 = (select 对外已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 对外未确认 = (select 对外未确认 from 函数更新_车辆管理_费用承担(a.id)), 
						 车主已确认 = (select 车主已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车主未确认 = (select 车主未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员已确认 = (select 驾驶员已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员未确认 = (select 驾驶员未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车队承担 = (select 车队承担 from 函数更新_车辆管理_费用承担(a.id)),
						 更新时间 = getdate()
	from 车辆_车辆费用实体 as a inner join 车辆_事故 as b on a.id = b.id
	
	update 车辆_车辆费用实体 set 警示状态 = (select 警示状态 from 函数更新_车辆事故_警示状态(a.id))
	from 车辆_车辆费用实体 as a inner join 车辆_事故 as b on a.id = b.id
end



create proc [dbo].[过程更新_参数_发票单位]
as
begin
DELETE 参数_发票单位
INSERT INTO 参数_发票单位
SELECT A.单位 AS 名称, 'true' as IsActive  FROM 
财务_发票 AS A 
WHERE  A.单位 IS NOT NULL
GROUP BY A.单位

end



CREATE proc [dbo].[过程更新_业务备案_车辆产值]
as
begin


update 业务备案_车辆产值 set 
						   委托人已对账 = (select 委托人已对账 from 函数更新_业务备案_车辆产值_委托人已对账(a.id))
						   
from 业务备案_车辆产值 as a 
where 日期 is null or datediff(day,日期,getdate()) between 0 and 300
end



















create proc 过程更新_业务备案_任务_拆箱信息
as
begin
	update 业务备案_任务 set 放行时间 = case when a.放行时间 is null then b.放行时间 else a.放行时间 end,
							 查验时间 = case when a.查验时间 is null then b.商检查验时间 else a.查验时间 end
	from 业务备案_任务 as a inner join 视图查询交互_货代任务_All as b 
	on a.箱号 = b.箱号 and a.提单号 = b.提单号
	where a.任务类别 = 1 and a.委托人 = '900008' and (a.放行时间 is null or a.查验时间 is null)
end
create proc [dbo].[过程更新_查询_资金日记帐_行数]
as
begin
delete 查询_资金日记帐_行数
insert into 查询_资金日记帐_行数 (金额,收付标志,ID,币制,源,日期,相关号码,摘要,当前行数)
(select * from 视图查询_资金日记帐_行数)
end


CREATE proc [dbo].[过程更新_财务_费用信息]
as
begin
	update 财务_费用信息 set 对外已确认 = (select 对外已确认 from 函数更新_财务_费用信息(a.id)),
						 对外未确认 = (select 对外未确认 from 函数更新_财务_费用信息(a.id)), 
						 车主已确认 = (select 车主已确认 from 函数更新_财务_费用信息(a.id)),
						 车主未确认 = (select 车主未确认 from 函数更新_财务_费用信息(a.id)),
						 驾驶员已确认 = (select 驾驶员已确认 from 函数更新_财务_费用信息(a.id)),
						 驾驶员未确认 = (select 驾驶员未确认 from 函数更新_财务_费用信息(a.id)),
						 委托人已确认 = (select 委托人已确认 from 函数更新_财务_费用信息(a.id)),
						 委托人未确认 = (select 委托人未确认 from 函数更新_财务_费用信息(a.id)),
						 车队承担 = (select 车队承担 from 函数更新_财务_费用信息(a.id)),
						 更新时间 = getdate(),
						 
						 委托人理论值 = (select 委托人理论值 from 函数更新_财务_理论值(a.车辆产值, a.费用项)), 
						 车主理论值 = (select 车主理论值 from 函数更新_财务_理论值(a.车辆产值, a.费用项)), 
						 驾驶员理论值 = (select 驾驶员理论值 from 函数更新_财务_理论值(a.车辆产值, a.费用项)), 
						 对外理论值 = (select 对外理论值 from 函数更新_财务_理论值(a.车辆产值, a.费用项)) 
	from 财务_费用信息 as a where submitted = 0

	update 财务_费用信息 set 警示状态 = (select 警示状态 from 函数更新_费用信息_警示状态(a.id))
	from 财务_费用信息 as a where submitted = 0

end



CREATE proc [dbo].[过程更新_库存加油_警示状态]
as
begin
	update 车辆_车辆费用实体 set 对外已确认 = (select 对外已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 对外未确认 = (select 对外未确认 from 函数更新_车辆管理_费用承担(a.id)), 
						 车主已确认 = (select 车主已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车主未确认 = (select 车主未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员已确认 = (select 驾驶员已确认 from 函数更新_车辆管理_费用承担(a.id)),
						 驾驶员未确认 = (select 驾驶员未确认 from 函数更新_车辆管理_费用承担(a.id)),
						 车队承担 = (select 车队承担 from 函数更新_车辆管理_费用承担(a.id)),
						 更新时间 = getdate()
	from 车辆_车辆费用实体 as a inner join 车辆_库存加油 as b on a.id = b.id
	
	update 车辆_车辆费用实体 set 警示状态 = (select 警示状态 from 函数更新_库存加油_警示状态(a.id))
	from 车辆_车辆费用实体 as a inner join 车辆_库存加油 as b on a.id = b.id
end



CREATE proc [dbo].[过程更新_财务_对账单]
as
begin
	update 财务_对账单 set 凭证号= c.凭证号,凭证=c.凭证
	from (select a.对账单,a.凭证号 ,a.凭证
	FROM 视图查询_费用明细 as a
	where a.对账单 is not null and a.凭证费用明细 is not null group by a.对账单,a.凭证号,a.凭证) as c
	inner join 财务_对账单 as b on c.对账单 = b.id

end


CREATE VIEW [dbo].[视图查询_现金日记帐_行数]
AS
SELECT     p2.金额, p2.存取标志, p2.ID, p2.币制, p2.源, P2.日期, P2.相关号码, P2.摘要, ROW_NUMBER() OVER (PARTITION BY p2.币制
ORDER BY p2.日期, p2.ID) AS 当前行数
FROM         视图查询_现金日记帐 AS p2




CREATE VIEW [dbo].[视图查询_现金日记帐_余额]
AS
SELECT     ID, 币制, 源, 当前行数, 日期, 相关号码, 摘要, CASE t2.存取标志 WHEN 1 THEN t2.金额 ELSE NULL END AS 贷, 
                      CASE t2.存取标志 WHEN 2 THEN t2.金额 ELSE NULL END AS 借,
                          (SELECT     SUM(CASE WHEN t1.存取标志 = 2 THEN t1.金额 ELSE 0 - t1.金额 END) AS 目前为止合计
                            FROM          dbo.查询_现金日记帐_行数 AS t1
                            WHERE      (当前行数 <= t2.当前行数) AND (币制 = t2.币制)) AS 目前为止合计
FROM         dbo.查询_现金日记帐_行数 AS t2




CREATE VIEW [dbo].[视图查询_押金]
AS
SELECT     A.日期, A.业务类型, A.费用项, A.金额, A.相关人, A.收付标志, B.凭证号,
                          (SELECT     dbo.Concatenate(DISTINCT 备注) AS Expr1
                            FROM          dbo.财务_凭证费用明细 AS X
                            WHERE      (凭证 = A.应收应付源)) AS 用途, B.备注, CASE 收付标志 WHEN 1 THEN '公司押给他人' ELSE '他人押在公司' END AS 类型
FROM         dbo.财务_应收应付款 AS A INNER JOIN
                      dbo.信息_费用类别 AS C ON A.业务类型 = C.代码 LEFT OUTER JOIN
                      dbo.财务_凭证 AS B ON A.应收应付源 = B.Id
WHERE     (A.费用项 = '002') AND (C.支出类别 = 205)


CREATE VIEW [dbo].[视图查询_业务费用_车队]
AS
SELECT     SUM(CASE WHEN 费用类别 IN (1, 2, 3, 4) AND 费用归属 = 1 AND 收付标志 = 1 THEN 金额 WHEN 费用类别 IN (1, 2, 3, 4) AND 费用归属 = 1 AND 
                      收付标志 = 2 THEN - 金额 ELSE 0 END) AS 产值, SUM(CASE WHEN 费用类别 IN (1, 2, 3, 4) AND 费用归属 = 2 AND 
                      收付标志 = 2 THEN 金额 WHEN 费用类别 IN (1, 2, 3, 4) AND 费用归属 = 2 AND 收付标志 = 1 THEN - 金额 ELSE 0 END) AS 应付, 
                      SUM(CASE WHEN 费用项 = 335 AND 费用归属 = 4 AND 收付标志 = 2 THEN 金额 WHEN 费用项 = 335 AND 费用归属 = 4 AND 
                      收付标志 = 1 THEN - 金额 ELSE 0 END) AS 扣税, SUM(CASE WHEN 费用类别 = 22 AND 收付标志 = 2 THEN 金额 WHEN 费用类别 = 22 AND 
                      收付标志 = 1 THEN - 金额 ELSE 0 END) AS 额外, SUM(CASE WHEN 费用类别 NOT IN (1, 2, 3, 4, 22) AND 
                      收付标志 = 2 THEN 金额 WHEN 费用类别 NOT IN (1, 2, 3, 4, 22) AND 收付标志 = 1 THEN - 金额 ELSE 0 END) AS 其他, 
                      SUM(CASE WHEN 收付标志 = 1 THEN 金额 WHEN 收付标志 = 2 THEN - 金额 ELSE 0 END) AS 小计, 费用实体
FROM         dbo.财务_费用
WHERE     (费用类型 = 21)
GROUP BY 费用实体


CREATE VIEW [dbo].[视图查询_业务费用_车辆]
AS
SELECT     SUM(CASE WHEN 费用类别 IN (1, 2, 3, 4) AND 收付标志 = 2 THEN 金额 WHEN 费用类别 IN (1, 2, 3, 4) AND 收付标志 = 1 THEN - 金额 ELSE 0 END) 
                      AS 运费, SUM(CASE WHEN 费用项 = 201 AND 收付标志 = 1 THEN 金额 WHEN 费用项 = 201 AND 收付标志 = 2 THEN - 金额 ELSE 0 END) AS 工资, 
                      SUM(CASE WHEN 费用项 = 202 AND 收付标志 = 1 THEN 金额 WHEN 费用项 = 202 AND 收付标志 = 2 THEN - 金额 ELSE 0 END) AS 话费补贴, 
                      SUM(CASE WHEN 费用项 = 203 AND 收付标志 = 1 THEN 金额 WHEN 费用项 = 203 AND 收付标志 = 2 THEN - 金额 ELSE 0 END) AS 轮胎补贴, 
                      SUM(CASE WHEN 费用项 = 205 AND 收付标志 = 1 THEN 数量 WHEN 费用项 = 205 AND 收付标志 = 2 THEN - 数量 ELSE 0 END) AS 定耗油, 
                      SUM(CASE WHEN 费用项 = 205 AND 收付标志 = 1 THEN 金额 WHEN 费用项 = 205 AND 收付标志 = 2 THEN - 金额 ELSE 0 END) AS 定耗油金额, 
                      SUM(CASE WHEN 费用项 = 211 AND 收付标志 = 1 THEN 金额 WHEN 费用项 = 211 AND 收付标志 = 2 THEN - 金额 ELSE 0 END) AS 路桥费, 
                      SUM(CASE WHEN 费用类别 = 323 AND 收付标志 = 2 THEN 金额 WHEN 费用类别 = 323 AND 收付标志 = 1 THEN - 金额 ELSE 0 END) AS 任务代付费, 
                      SUM(CASE WHEN 费用类别 = 329 AND 收付标志 = 2 THEN 金额 WHEN 费用类别 = 329 AND 收付标志 = 1 THEN - 金额 ELSE 0 END) AS 其他承担, 
                      SUM(CASE WHEN 费用类别 = 322 AND 收付标志 = 2 THEN 金额 WHEN 费用类别 = 322 AND 收付标志 = 1 THEN - 金额 ELSE 0 END) AS 额外承担, 
                      SUM(CASE WHEN 收付标志 = 2 THEN 金额 WHEN 收付标志 = 1 THEN - 金额 ELSE 0 END) AS 小计, 费用实体
FROM         dbo.财务_费用
WHERE     (费用类型 = 21) AND (费用归属 = 2)
GROUP BY 费用实体


CREATE VIEW [dbo].[视图查询_业务费用_对外支出]
AS
SELECT     SUM(CASE WHEN 费用项 = 335 AND 收付标志 = 2 THEN 金额 WHEN 费用项 = 335 AND 收付标志 = 1 THEN - 金额 ELSE 0 END) AS 开票税, 
                      SUM(CASE WHEN 费用项 = 211 AND 收付标志 = 2 THEN 金额 WHEN 费用项 = 211 AND 收付标志 = 1 THEN - 金额 ELSE 0 END) AS 路桥费, 
                      SUM(CASE WHEN 费用项 = 111 AND 收付标志 = 2 THEN 金额 WHEN 费用项 = 111 AND 收付标志 = 1 THEN - 金额 ELSE 0 END) AS 吊机费, 
                      SUM(CASE WHEN 费用类别 = 323 AND 收付标志 = 2 THEN 金额 WHEN 费用类别 = 323 AND 收付标志 = 1 THEN - 金额 ELSE 0 END) AS 任务代付费, 
                      SUM(CASE WHEN 费用类别 = 329 AND 收付标志 = 2 THEN 金额 WHEN 费用类别 = 329 AND 收付标志 = 1 THEN - 金额 ELSE 0 END) AS 其他支出, 
                      SUM(CASE WHEN 费用项 = 204 AND 收付标志 = 2 THEN 数量 WHEN 费用项 = 204 AND 收付标志 = 1 THEN - 数量 ELSE 0 END) AS 实耗油, 
                      SUM(CASE WHEN 费用项 = 204 AND 收付标志 = 2 THEN 金额 WHEN 费用项 = 204 AND 收付标志 = 1 THEN - 金额 ELSE 0 END) AS 实耗油金额, 
                      SUM(CASE WHEN 收付标志 = 2 THEN 金额 WHEN 收付标志 = 1 THEN - 金额 ELSE 0 END) AS 小计, 费用实体
FROM         dbo.财务_费用
WHERE     (费用类型 = 21) AND (费用归属 = 4)
GROUP BY 费用实体


CREATE VIEW [dbo].[视图查询_业务费用_驾驶员]
AS
SELECT     SUM(CASE WHEN 费用项 = 201 AND 收付标志 = 2 THEN 金额 WHEN 费用项 = 201 AND 收付标志 = 1 THEN - 金额 ELSE 0 END) AS 工资, 
                      SUM(CASE WHEN 费用项 = 202 AND 收付标志 = 2 THEN 金额 WHEN 费用项 = 202 AND 收付标志 = 1 THEN - 金额 ELSE 0 END) AS 话费补贴, 
                      SUM(CASE WHEN 费用项 = 203 AND 收付标志 = 2 THEN 金额 WHEN 费用项 = 203 AND 收付标志 = 1 THEN - 金额 ELSE 0 END) AS 轮胎补贴, 
                      SUM(CASE WHEN 费用项 IN (204, 205) AND 收付标志 = 2 THEN 数量 WHEN 费用项 IN (204, 205) AND 收付标志 = 1 THEN - 数量 ELSE 0 END) 
                      AS 超节油, SUM(CASE WHEN 费用项 IN (204, 205) AND 收付标志 = 2 THEN 金额 WHEN 费用项 IN (204, 205) AND 
                      收付标志 = 1 THEN - 金额 ELSE 0 END) AS 超节油金额, SUM(CASE WHEN 费用类别 = 329 AND 收付标志 = 1 THEN 金额 WHEN 费用类别 = 329 AND 
                      收付标志 = 2 THEN - 金额 ELSE 0 END) AS 其他收入, SUM(CASE WHEN 费用类别 = 322 AND 收付标志 = 2 THEN 金额 WHEN 费用类别 = 322 AND 
                      收付标志 = 1 THEN - 金额 ELSE 0 END) AS 额外承担, SUM(CASE WHEN 收付标志 = 2 THEN 金额 WHEN 收付标志 = 1 THEN - 金额 ELSE 0 END) 
                      AS 小计, 费用实体, 相关人
FROM         dbo.财务_费用
WHERE     (费用类型 = 21) AND (费用归属 = 3)
GROUP BY 费用实体, 相关人


CREATE VIEW dbo.视图查询_业务费用_利润分成
AS
SELECT     费用实体, SUM(CASE WHEN 车辆承担 = 0 AND 收付标志 = 1 THEN 金额 WHEN 车辆承担 = 0 AND 收付标志 = 2 THEN - 金额 ELSE 0 END) AS 车队利润, 
                      SUM(CASE WHEN (收付标志 = 2 AND 费用归属 = 2) OR
                      (收付标志 = 1 AND 车辆承担 = 1) THEN 金额 WHEN (收付标志 = 1 AND 费用归属 = 2) OR
                      (收付标志 = 2 AND 车辆承担 = 1) THEN - 金额 ELSE 0 END) AS 车辆利润, SUM(CASE WHEN 收付标志 = 2 AND 
                      费用归属 = 3 THEN 金额 WHEN 收付标志 = 1 AND 费用归属 = 3 THEN - 金额 ELSE 0 END) AS 驾驶员利润
FROM         dbo.财务_费用
WHERE     (费用类型 = 21)
GROUP BY 费用实体

CREATE VIEW [dbo].[视图查询_业务费用_委托人]
AS
SELECT     SUM(CASE WHEN 费用类别 IN (1, 2, 3, 4) AND 收付标志 = 1 THEN 金额 WHEN 费用类别 IN (1, 2, 3, 4) AND 收付标志 = 2 THEN - 金额 ELSE 0 END) 
                      AS 产值, SUM(CASE WHEN 费用类别 = 323 AND 收付标志 = 1 THEN 金额 WHEN 费用类别 = 323 AND 收付标志 = 2 THEN - 金额 ELSE 0 END) 
                      AS 任务代付费, SUM(CASE WHEN 费用类别 = 329 AND 收付标志 = 1 THEN 金额 WHEN 费用类别 = 329 AND 收付标志 = 2 THEN - 金额 ELSE 0 END) 
                      AS 其他承担, SUM(CASE WHEN 费用类别 = 322 AND 收付标志 = 2 THEN 金额 WHEN 费用类别 = 322 AND 收付标志 = 1 THEN - 金额 ELSE 0 END) 
                      AS 委托人额外, SUM(CASE WHEN 收付标志 = 1 THEN 金额 WHEN 收付标志 = 2 THEN - 金额 ELSE 0 END) AS 小计, 费用实体, 任务
FROM         dbo.财务_费用
WHERE     (费用类型 = 21) AND (费用归属 = 1)
GROUP BY 费用实体, 任务


CREATE VIEW dbo.视图查询_银行日记帐
AS
SELECT     CASE 支票类型 WHEN 1 THEN '现金支票取' ELSE '转账支票取' END AS 源, Id, 日期, 2 AS 存取标志, 银行账户, 金额, 摘要, Id AS 信息主表Id, 
                      票据号码 AS 相关号码
FROM         dbo.财务_支票 AS 支票取
WHERE     (Submitted = 1)
UNION ALL
SELECT     '转账支票存' AS 源, Id, 日期, 1 AS Expr1, 入款账户, 金额, 摘要, Id AS 信息主表Id, 票据号码 AS 相关号码
FROM         dbo.财务_支票 AS 转账支票存
WHERE     (支票类型 = 2) AND (支付凭证号 IS NULL) AND (Submitted = 1)
UNION ALL
SELECT     '银行存取' AS 源, Id, 日期, 存取标志, 银行账户, 金额, 备注, Id AS 信息主表Id, 编号 AS 相关号码
FROM         dbo.财务_银行存取款
UNION ALL
SELECT     (CASE WHEN 出款币制 = 入款币制 THEN '转账取' ELSE '换汇取' END) AS 源, Id, 日期, 2 AS 存取标志, 出款账户 AS 银行账户, 出款数额 AS 金额, 备注, 
                      Id AS 信息主表Id, 编号 AS 相关号码
FROM         dbo.财务_换汇 AS 换汇取
WHERE     (出款账户 IS NOT NULL)
UNION ALL
SELECT     (CASE WHEN 出款币制 = 入款币制 THEN '转账存' ELSE '换汇存' END) AS 源, Id, 日期, 1 AS 存取标志, 入款账户 AS 银行账户, 入款数额 AS 金额, 备注, 
                      Id AS 信息主表Id, 编号 AS 相关号码
FROM         dbo.财务_换汇 AS 换汇存
WHERE     (入款账户 IS NOT NULL)
UNION ALL
SELECT     '凭证银行收付' AS 源, X.Id, P.日期, X.收付标志 AS 存取标志, X.银行账户, X.金额, P.摘要, P.Id AS 信息主表Id, P.凭证号 AS 相关号码
FROM         dbo.财务_凭证收支明细 AS X INNER JOIN
                      dbo.财务_凭证 AS P ON X.凭证 = P.Id AND P.收支状态 = 1
WHERE     (X.收付款方式 = 5) OR
                      (X.收付款方式 = 6) OR
                      (X.收付款方式 = 7)

CREATE VIEW [dbo].[视图查询_银行日记帐_行数]
AS
SELECT     p2.金额, p2.存取标志, p2.ID, p2.银行账户, p2.源, P2.日期, P2.相关号码, P2.摘要, ROW_NUMBER() OVER (PARTITION BY p2.银行账户
ORDER BY p2.日期, p2.ID) AS 当前行数
FROM         视图查询_银行日记帐 AS p2




CREATE VIEW [dbo].[视图查询_银行日记帐_余额]
AS
SELECT     t2.ID, t2.银行账户, Y.币制, t2.源, t2.当前行数, t2.日期, t2.相关号码, t2.摘要, CASE t2.存取标志 WHEN 1 THEN t2.金额 ELSE NULL END AS 借, 
                      CASE t2.存取标志 WHEN 2 THEN t2.金额 ELSE NULL END AS 贷,
                          (SELECT     SUM(CASE WHEN t1.存取标志 = 1 THEN t1.金额 ELSE 0 - t1.金额 END) AS 目前为止合计
                            FROM          dbo.查询_银行日记帐_行数 AS t1
                            WHERE      (当前行数 <= t2.当前行数) AND (银行账户 = t2.银行账户)) AS 目前为止合计
FROM         dbo.查询_银行日记帐_行数 AS t2 INNER JOIN
                      dbo.参数备案_银行账户 AS Y ON t2.银行账户 = Y.Id




CREATE VIEW [dbo].[视图查询_支票]
AS
SELECT     '公司支票' AS 源, C.Id, C.支票类型, C.票据号码, C.银行账户, C.金额, Y.币制, C.备注, C.摘要, C.日期, C.支付凭证号 AS 凭证号, C.是否作废, 
                      C.Submitted
FROM         dbo.财务_支票 AS C INNER JOIN
                      dbo.参数备案_银行账户 AS Y ON C.银行账户 = Y.Id
UNION ALL
SELECT     '外部支票' AS 源, B.Id, CASE B.收付款方式 WHEN 2 THEN '1' WHEN 3 THEN '2' END AS 支票类型, B.票据号码, NULL AS 银行账户, B.金额, 
                      A.币制, NULL AS 备注, NULL AS 摘要, A.日期, A.凭证号, A.是否作废, A.Submitted
FROM         dbo.财务_凭证 AS A INNER JOIN
                      dbo.财务_凭证收支明细 AS B ON A.Id = B.凭证
WHERE     (B.收付款方式 = 2 OR
                      B.收付款方式 = 3) AND (B.收付标志 = 1) AND (A.是否作废 = 0) AND (A.Submitted = 1)




CREATE VIEW [dbo].[视图查询_支票_过程结束]
AS
SELECT     '支出' AS 源, C.Id, NULL AS 入款账户, A.摘要 AS 凭证摘要, B.凭证, A.凭证号, C.日期, C.票据号码
FROM         dbo.财务_凭证 AS A INNER JOIN
                      dbo.财务_凭证收支明细 AS B ON A.Id = B.凭证 INNER JOIN
                      dbo.财务_支票 AS C ON B.票据号码 = C.票据号码
UNION ALL
SELECT     '提现' AS 源, C.Id, NULL AS 入款账户, NULL AS 凭证摘要, NULL AS 凭证, NULL AS 凭证号, C.日期, C.票据号码
FROM         dbo.财务_支票 AS C INNER JOIN
                      dbo.参数备案_银行账户 AS Y ON C.银行账户 = Y.Id
WHERE     (C.支票类型 = 1) AND (C.支付凭证号 IS NULL) AND (C.Submitted = 1)
UNION ALL
SELECT     '转账' AS 源, C.Id, C.入款账户, NULL AS 凭证摘要, NULL AS 凭证, NULL AS 凭证号, C.日期, C.票据号码
FROM         dbo.财务_支票 AS C INNER JOIN
                      dbo.参数备案_银行账户 AS Y ON C.银行账户 = Y.Id
WHERE     (C.支票类型 = 2) AND (C.支付凭证号 IS NULL) AND (C.Submitted = 1)
UNION ALL
SELECT     '作废' AS 源, C.Id, NULL AS 入款账户, NULL AS 凭证摘要, NULL AS 凭证, NULL AS 凭证号, C.日期, C.票据号码
FROM         dbo.财务_支票 AS C INNER JOIN
                      dbo.参数备案_银行账户 AS Y ON C.银行账户 = Y.Id
WHERE     (C.是否作废 = 1)
UNION ALL
SELECT     '收入' AS 源, B.Id, B.银行账户 AS 入款账户, A.摘要 AS 凭证摘要, B.凭证, A.凭证号, A.日期, B.票据号码
FROM         dbo.财务_凭证 AS A INNER JOIN
                      dbo.财务_凭证收支明细 AS B ON A.Id = B.凭证
WHERE     (B.收付款方式 = 2 OR
                      B.收付款方式 = 3) AND (B.收付标志 = 1)




CREATE VIEW [dbo].[视图查询_支票_过程在途]
AS
SELECT     '过程在途' AS 源, C.Id, C.买入时间, C.领用时间, C.经办人, C.领用方式, C.票据号码
FROM         dbo.财务_支票 AS C INNER JOIN
                      dbo.参数备案_银行账户 AS Y ON C.银行账户 = Y.Id




CREATE VIEW [dbo].[视图查询_资金流水明细]
AS
SELECT     '凭证' AS 源, P.Id, B.收付标志, P.日期, P.币制, B.金额, P.摘要, P.Id AS 信息主表Id, P.凭证号 AS 相关号码, B.收付款方式,
                          (SELECT     dbo.Concatenate(DISTINCT 相关人) AS Expr1
                            FROM          dbo.财务_凭证费用明细 AS X
                            WHERE      (凭证 = P.Id)) AS 相关人,
                          (SELECT     dbo.Concatenate(DISTINCT 费用项) AS Expr1
                            FROM          dbo.财务_凭证费用明细 AS X
                            WHERE      (凭证 = P.Id)) AS 费用项, P.备注
FROM         dbo.财务_凭证 AS P INNER JOIN
                      dbo.财务_凭证收支明细 AS B ON P.Id = B.凭证
WHERE     (P.收支状态 = 1) AND (P.Submitted = 1)
UNION
SELECT     '换汇出款' AS 源, Id, 2 AS 收付标志, 日期, 出款币制 AS 币制, 出款数额 AS 金额, 摘要, Id AS 信息主表Id, 编号 AS 相关号码, 
                      CASE WHEN 出款账户 IS NULL THEN 1 ELSE 6 END AS 收付款方式, 经办人 AS 相关人, NULL AS 费用项, 备注
FROM         dbo.财务_换汇 AS 换汇出
UNION ALL
SELECT     '换汇入款' AS 源, Id, 1 AS 收付标志, 日期, 入款币制 AS 币制, 入款数额 AS 金额, 摘要, Id AS 信息主表Id, 编号 AS 相关号码, 
                      CASE WHEN 入款账户 IS NULL THEN 1 ELSE 6 END AS 收付款方式, 经办人 AS 相关人, NULL AS 费用项, 备注
FROM         dbo.财务_换汇 AS 换汇入




CREATE VIEW dbo.视图查询交互_货代任务_All
AS
SELECT     委托人, 任务类别, 货代自编号, 提单号, 船公司, 箱量, 提箱地, 指运地, 装卸货地, 还箱地, 货代提箱时间要求止, 货代还箱时间要求止, 箱号, 箱型, 
                      委托时间, 回货箱号, 到港时间, CASE WHEN 商检查验 IS NULL THEN NULL ELSE 商检查验时间 END AS 商检查验时间, 转关标志, 提箱时间, 还箱时间, 
                      放行时间, 白卡排车时间, 船名航次
FROM         OPENDATASOURCE ('SQLOLEDB', 
                      'Data Source=ykbg8.ticp.net, 8033;Initial Catalog=jkhd2;User ID=sa;Password=qazwsxedc' ).jkhd2.dbo.视图查询_车队任务 AS derivedtbl_1

CREATE VIEW dbo.视图查询_资金日记帐
AS
SELECT     '凭证' AS 源, Id, 凭证类别 AS 收付标志, 日期, 币制, 数额 AS 金额, 摘要, Id AS 信息主表Id, 凭证号 AS 相关号码
FROM         dbo.财务_凭证 AS P
WHERE     (收支状态 = 1) AND (Submitted = 1)
UNION
SELECT     '换汇出款' AS 源, Id, 2 AS 收付标志, 日期, 出款币制 AS 币制, 出款数额 AS 金额, 摘要, Id AS 信息主表Id, 编号 AS 相关号码
FROM         dbo.财务_换汇 AS 换汇出
WHERE     (出款币制 <> 入款币制)
UNION ALL
SELECT     '换汇入款' AS 源, Id, 1 AS 收付标志, 日期, 入款币制 AS 币制, 入款数额 AS 金额, 摘要, Id AS 信息主表Id, 编号 AS 相关号码
FROM         dbo.财务_换汇 AS 换汇入
WHERE     (出款币制 <> 入款币制)

CREATE VIEW dbo.视图信息_车辆维修项目
AS
SELECT     dbo.车辆_维修.项目, dbo.车辆_车辆费用实体.相关人
FROM         dbo.车辆_维修 INNER JOIN
                      dbo.车辆_车辆费用实体 ON dbo.车辆_维修.Id = dbo.车辆_车辆费用实体.Id

CREATE VIEW [dbo].[视图查询_资金日记帐_行数]
AS
SELECT     p2.金额, p2.收付标志, p2.ID, p2.币制, p2.源, P2.日期, P2.相关号码, P2.摘要, ROW_NUMBER() OVER (PARTITION BY p2.币制
ORDER BY p2.日期, p2.ID) AS 当前行数
FROM         视图查询_资金日记帐 AS p2




CREATE VIEW [dbo].[视图查询_资金日记帐_余额]
AS
SELECT     ID, 币制, 源, 当前行数, 日期, 相关号码, 摘要, CASE t2.收付标志 WHEN 1 THEN t2.金额 ELSE NULL END AS 借, 
                      CASE t2.收付标志 WHEN 2 THEN t2.金额 ELSE NULL END AS 贷,
                          (SELECT     SUM(CASE WHEN t1.收付标志 = 1 THEN t1.金额 ELSE 0 - t1.金额 END) AS 目前为止合计
                            FROM          dbo.查询_资金日记帐_行数 AS t1
                            WHERE      (当前行数 <= t2.当前行数) AND (币制 = t2.币制)) AS 目前为止合计
FROM         dbo.查询_资金日记帐_行数 AS t2




CREATE VIEW [dbo].[视图对账单金额]
AS
SELECT     SUM(金额) AS 金额, 对账单
FROM         dbo.财务_费用
WHERE     (对账单 IS NOT NULL)
GROUP BY 对账单




CREATE VIEW [dbo].[视图查询驾驶员月报表_费用明细_业务]
AS
SELECT     '业务' AS 源, 收付标志, '车辆产值' AS 小类, '业务' AS 大类, 日期, 承运车辆, 承运人, 驾驶员, 路线, 装卸货地, 委托人, 货代自编号, 箱号, 箱型, 车辆产值,
                       趟任务类别, 车辆类别, 完全标志, 费用项, 相关人, 收款金额, 付款金额, 费用类型, 费用类别, 凭证号, 备注, 车辆, 费用实体, 对账单, 凭证费用明细, 
                      任务, 费用信息, 数量, 凭证, 对账单号, 对账单提交, 入账日期, 费用归属, 相关号, 费用实体类型, Created, 任务类别, 金额
FROM         dbo.视图查询_费用明细_费用类型_业务
WHERE     (费用归属 = 3)


CREATE VIEW dbo.视图查询车辆月报表_费用明细_业务
AS
SELECT     '业务' AS 源, CASE WHEN 收付标志 = 2 AND 费用类别 IN (1, 2, 3, 4) THEN 2 ELSE 1 END AS 收付标志, '车辆产值' AS 小类, '业务' AS 大类, 日期, 
                      承运车辆, 承运人, 驾驶员, 路线, 装卸货地, 委托人, 货代自编号, 箱号, 箱型, 车辆产值, 趟任务类别, 车辆类别, 完全标志, 费用项, 相关人, 收款金额, 
                      付款金额, 费用类型, 费用类别, 凭证号, 备注, 车辆, 费用实体, 对账单, 凭证费用明细, 任务, 费用信息, 数量, 凭证, 对账单号, 对账单提交, 入账日期, 
                      费用归属, 相关号, 费用实体类型, Created, Updated, 任务类别, CASE WHEN 收付标志 = 2 AND 费用类别 NOT IN (1, 2, 3, 4) 
                      THEN - 金额 ELSE 金额 END AS 金额
FROM         dbo.视图查询_费用明细_费用类型_业务
WHERE     (费用归属 = 2) AND (车辆类别 = 1 OR
                      车辆类别 = 2)
UNION ALL
SELECT     '业务' AS 源, CASE WHEN 收付标志 = 1 AND 费用类别 IN (1, 2, 3, 4) THEN 2 ELSE 1 END AS 收付标志, '车辆产值' AS 小类, '业务' AS 大类, 日期, 
                      承运车辆, 承运人, 驾驶员, 路线, 装卸货地, 委托人, 货代自编号, 箱号, 箱型, 车辆产值, 趟任务类别, 车辆类别, 完全标志, 费用项, 相关人, 收款金额, 
                      付款金额, 费用类型, 费用类别, 凭证号, 备注, 车辆, 费用实体, 对账单, 凭证费用明细, 任务, 费用信息, 数量, 凭证, 对账单号, 对账单提交, 入账日期, 
                      费用归属, 相关号, 费用实体类型, Created, Updated, 任务类别, CASE WHEN 收付标志 = 1 AND 费用类别 NOT IN (1, 2, 3, 4) 
                      THEN - 金额 ELSE 金额 END AS 金额
FROM         dbo.视图查询_费用明细_费用类型_业务 AS 视图查询_费用明细_费用类型_业务_1
WHERE     (车辆承担 = 1)

CREATE VIEW dbo.视图查询车队月报表_费用明细_自有车辆业务
AS
SELECT     '自有车辆业务' AS 源, 2 AS 收付标志, B.小类, '自有车辆业务' AS 大类, A.日期, A.承运车辆, A.承运人, A.驾驶员, A.路线, A.装卸货地, A.委托人, 
                      A.货代自编号, A.箱号, A.箱型, A.车辆产值, A.趟任务类别, A.车辆类别, A.完全标志, A.费用项, A.相关人, A.收款金额, A.付款金额, A.费用类型, A.费用类别, 
                      A.凭证号, A.备注, A.车辆, CASE WHEN a.收付标志 = 1 THEN - A.金额 ELSE A.金额 END AS 金额, A.费用实体, A.对账单, A.凭证费用明细, A.任务, 
                      A.费用信息, A.数量, A.凭证, A.对账单号, A.对账单提交, A.入账日期, A.费用归属, A.相关号, A.费用实体类型, A.Created, A.任务类别, A.车辆承担, 
                      A.Updated
FROM         dbo.视图查询_费用明细_费用类型_业务 AS A INNER JOIN
                      dbo.信息_费用类别 AS B ON A.费用类别 = B.代码
WHERE     (A.车辆承担 = 1)

CREATE VIEW dbo.视图查询车队月报表_费用明细_业务
AS
SELECT     '业务' AS 源, CASE WHEN (费用归属 = 1 AND 收付标志 = 1) OR
                      (费用归属 <> 1 AND 收付标志 = 2) THEN 金额 ELSE - 金额 END AS 金额, CASE WHEN 费用归属 = 1 THEN 1 ELSE 2 END AS 收付标志, 
                      CASE WHEN 费用归属 = 1 AND 相关人 = 900008 THEN '自己货代' WHEN 费用归属 = 1 AND 
                      相关人 <> 900008 THEN '别的货代' WHEN 费用项 = 204 THEN '加油' WHEN 费用归属 = 4 AND 费用项 = 335 THEN '扣税' WHEN 费用归属 <> 1 AND 
                      (车辆类别 > 2 OR
                      车辆类别 IS NULL) AND 费用项 NOT IN (335, 204) THEN '挂靠车辆' WHEN 费用归属 <> 1 AND 车辆类别 = 2 AND 费用项 NOT IN (335, 204) 
                      THEN '代管车辆' ELSE '自有车辆' END AS 小类, '车队业务' AS 大类, 日期, 承运车辆, 承运人, 驾驶员, 路线, 装卸货地, 委托人, 货代自编号, 箱号, 箱型, 
                      车辆产值, 趟任务类别, ISNULL(车辆类别, 3) AS 车辆类别, 完全标志, 费用项, 相关人, 收款金额, 付款金额, 费用类型, 费用类别, 凭证号, 备注, 车辆, 
                      费用实体, 对账单, 凭证费用明细, 任务, 费用信息, 数量, 凭证, 对账单号, 对账单提交, 入账日期, 费用归属, 相关号, 费用实体类型, Created, Updated, 
                      任务类别
FROM         dbo.视图查询_费用明细_费用类型_业务 AS A
WHERE     (费用归属 = 1) OR
                      (车辆类别 <> 1) OR
                      (费用项 = 335) OR
                      (费用项 = 204) OR
                      (车辆类别 IS NULL)

CREATE VIEW dbo.视图查询车队月报表_费用明细_非业务
AS
SELECT     '非业务' AS 源, B.小类, B.大类, A.收付标志, A.费用项, A.相关人, A.备注, A.对账单, A.凭证费用明细, A.入账日期, A.费用实体, A.金额, A.费用类别, 
                      A.对账单号, A.对账单提交, A.凭证, A.凭证号, A.费用实体类型, A.Created, A.相关号, A.费用类型, A.收款金额, A.付款金额, A.Updated
FROM         dbo.视图查询_费用明细_费用类型_非业务 AS A INNER JOIN
                      dbo.信息_费用类别 AS B ON A.费用类别 = B.代码

CREATE VIEW [dbo].[视图查询_费用信息_最大时间]
AS
SELECT     费用信息, MAX(最大时间) AS 最大时间
FROM         (SELECT     CAST(费用信息 AS uniqueidentifier) AS 费用信息, MAX(ISNULL(Updated, Created)) AS 最大时间
                       FROM          dbo.财务_费用 AS a
                       GROUP BY 费用信息
                       UNION ALL
                       SELECT     CAST(Id AS uniqueidentifier) AS 费用信息, MAX(ISNULL(Updated, Created)) AS 最大时间
                       FROM         dbo.财务_费用信息 AS a
                       GROUP BY Id) AS b
GROUP BY 费用信息



CREATE VIEW dbo.视图查询_借贷
AS
SELECT     A.日期, A.结算期限, A.业务类型, A.费用项, A.金额, A.相关人, A.收付标志, B.凭证号,
                          (SELECT     dbo.Concatenate(DISTINCT 收付款方式) AS Expr1
                            FROM          dbo.财务_凭证收支明细 AS X
                            WHERE      (凭证 = A.应收应付源)) AS 收付款方式,
                          (SELECT     dbo.Concatenate(DISTINCT 备注) AS Expr1
                            FROM          dbo.财务_凭证费用明细 AS X
                            WHERE      (凭证 = A.应收应付源)) AS 用途, B.备注, CASE 收付标志 WHEN 1 THEN '借出款' ELSE '贷款' END AS 类型, D.编号, D.源
FROM         dbo.财务_应收应付款 AS A INNER JOIN
                      dbo.信息_费用类别 AS C ON A.业务类型 = C.代码 LEFT OUTER JOIN
                      dbo.视图信息_应收应付源 AS D ON A.应收应付源 = D.Id LEFT OUTER JOIN
                      dbo.财务_凭证 AS B ON A.应收应付源 = B.Id
WHERE     (A.费用项 = '002') AND (C.支出类别 = 203)

CREATE VIEW [dbo].[视图查询_人员单位]
AS
SELECT     CASE substring(A.编号, 1, 2) WHEN '20' THEN '员工' ELSE '客户' END AS 源, A.编号, A.简称, A.全称, A.角色用途, A.联系方式, A.备注, A.IsActive, 
                      K.首次交往, K.信誉情况, K.简况, K.交往记录, Y.性别, Y.出生日期, Y.籍贯, Y.照片, Y.身份证号, Y.毕业院校, Y.学历, Y.专业, Y.政治面貌, Y.婚姻状况, 
                      Y.加入公司日期, Y.工作简历, Y.特长爱好
FROM         dbo.参数备案_人员单位 AS A LEFT OUTER JOIN
                      dbo.参数备案_人员单位_员工 AS Y ON Y.编号 = A.编号 LEFT OUTER JOIN
                      dbo.参数备案_人员单位_客户 AS K ON A.编号 = K.编号




CREATE VIEW [dbo].[视图查询_现金日记帐]
AS
SELECT     '现金支票提现' AS 源, Z.Id, Z.日期, 2 AS 存取标志, Z.金额, Y.币制, Z.摘要, Z.Id AS 信息主表Id, Z.票据号码 AS 相关号码
FROM         dbo.财务_支票 AS Z INNER JOIN
                      dbo.参数备案_银行账户 AS Y ON Z.银行账户 = Y.Id
WHERE     (Z.支票类型 = 1) AND (Z.支付凭证号 IS NULL) AND (Z.Submitted = 1)
UNION ALL
SELECT     '银行存取' AS 源, C.Id, C.日期, C.存取标志, C.金额, Y.币制, C.备注, C.Id AS 信息主表Id, C.编号 AS 相关号码
FROM         dbo.财务_银行存取款 AS C INNER JOIN
                      dbo.参数备案_银行账户 AS Y ON C.银行账户 = Y.Id
UNION ALL
SELECT     '换汇现金出款' AS 源, Id, 日期, 1 AS 存取标志, 出款数额 AS 金额, 出款币制 AS 币制, 摘要, Id AS 信息主表Id, 编号 AS 相关号码
FROM         dbo.财务_换汇 AS 换汇出
WHERE     (出款账户 IS NULL)
UNION ALL
SELECT     '换汇现金入款' AS 源, Id, 日期, 2 AS 存取标志, 入款数额 AS 金额, 入款币制 AS 币制, 摘要, Id AS 信息主表Id, 编号 AS 相关号码
FROM         dbo.财务_换汇 AS 换汇入
WHERE     (入款账户 IS NULL)
UNION ALL
SELECT     '凭证现金收付' AS 源, X.Id, P.日期, CASE X.收付标志 WHEN 1 THEN 2 ELSE 1 END AS 存取标志, X.金额, P.币制, P.摘要, P.Id AS 信息主表Id, 
                      P.凭证号 AS 相关号码
FROM         dbo.财务_凭证收支明细 AS X INNER JOIN
                      dbo.财务_凭证 AS P ON X.凭证 = P.Id AND P.收支状态 = 1
WHERE     (X.收付款方式 = 1) OR
                      (X.收付款方式 = 2) AND (X.收付标志 = 1)


CREATE VIEW [dbo].[视图信息_费用实体_非业务]
AS
SELECT     A.费用实体类型, A.Id, B.票据号码 AS 相关号, C.类型 AS 非业务
FROM         dbo.财务_费用实体 AS A INNER JOIN
                      dbo.财务_承兑汇票 AS B ON A.Id = B.Id AND A.费用实体类型 = 21 INNER JOIN
                      dbo.信息_费用类别 AS C ON A.费用实体类型 = C.代码
UNION ALL
SELECT     A.费用实体类型, A.Id, B.票据号码 AS 相关号, C.类型
FROM         dbo.财务_费用实体 AS A INNER JOIN
                      dbo.财务_发票 AS B ON A.Id = B.Id AND A.费用实体类型 = 23 INNER JOIN
                      dbo.信息_费用类别 AS C ON A.费用实体类型 = C.代码
UNION ALL
SELECT     A.费用实体类型, A.Id, A.编号 AS 相关号, C.类型
FROM         dbo.财务_费用实体 AS A INNER JOIN
                      dbo.信息_费用类别 AS C ON A.费用实体类型 = C.代码 AND C.非业务 = 1
WHERE     (C.类型 <> '发票') AND (C.类型 <> '承兑汇票')


CREATE VIEW dbo.报表_对账单_费用项
AS
SELECT     A.入账日期, A.对账单号, A.费用项, A.相关人, A.对账单收付标志, A.收付标志, A.收款金额, A.付款金额, CASE WHEN 对账单收付标志 = 1 AND 
                      收付标志 = 1 AND 金额 > 0 THEN 金额 WHEN 对账单收付标志 = 1 AND 收付标志 = 1 AND 金额 < 0 THEN - 金额 WHEN 对账单收付标志 = 1 AND 
                      收付标志 = 2 AND 金额 > 0 THEN - 金额 WHEN 对账单收付标志 = 1 AND 收付标志 = 2 AND 金额 < 0 THEN - 金额 WHEN 对账单收付标志 = 2 AND 
                      收付标志 = 2 AND 金额 > 0 THEN 金额 WHEN 对账单收付标志 = 2 AND 收付标志 = 2 AND 金额 < 0 THEN 金额 WHEN 对账单收付标志 = 2 AND 
                      收付标志 = 1 AND 金额 > 0 THEN - 金额 WHEN 对账单收付标志 = 2 AND 收付标志 = 1 AND 金额 < 0 THEN 金额 ELSE NULL END AS 金额, A.费用类别, 
                      A.费用实体类型名称, A.数量, B.货代自编号, B.箱号, B.回货箱号, B.箱型, C.承运人, C.驾驶员, C.公里, C.路线, C.日期, C.备注, A.起始日期, A.结束日期, 
                      A.费用归属, A.任务, A.费用实体, B.任务类别, A.车辆, B.指运地, B.提单号, B.船名航次
FROM         dbo.业务备案_车辆产值 AS C RIGHT OUTER JOIN
                      dbo.视图查询_费用明细 AS A LEFT OUTER JOIN
                      dbo.业务备案_任务 AS B ON A.任务 = B.Id ON C.Id = A.费用实体
WHERE     (A.对账单号 IS NOT NULL)

CREATE VIEW [dbo].[视图信息_费用实体_相关号]
AS
SELECT     A.费用实体类型, A.Id, B.票据号码 AS 相关号, C.类型
FROM         dbo.财务_费用实体 AS A INNER JOIN
                      dbo.财务_承兑汇票 AS B ON A.Id = B.Id AND A.费用实体类型 = 21 INNER JOIN
                      dbo.信息_费用类别 AS C ON A.费用实体类型 = C.代码
UNION ALL
SELECT     A.费用实体类型, A.Id, B.票据号码 AS 相关号, C.类型
FROM         dbo.财务_费用实体 AS A INNER JOIN
                      dbo.财务_发票 AS B ON A.Id = B.Id AND A.费用实体类型 = 23 INNER JOIN
                      dbo.信息_费用类别 AS C ON A.费用实体类型 = C.代码
UNION ALL
SELECT     A.费用实体类型, A.Id, B.简介 AS 相关号, C.类型
FROM         dbo.财务_费用实体 AS A INNER JOIN
                      dbo.财务_固定资产 AS B ON A.Id = B.Id AND A.费用实体类型 = 24 INNER JOIN
                      dbo.信息_费用类别 AS C ON A.费用实体类型 = C.代码
UNION ALL
SELECT     A.费用实体类型, A.Id, A.编号 AS 相关号, C.类型
FROM         dbo.财务_费用实体 AS A INNER JOIN
                      dbo.信息_费用类别 AS C ON A.费用实体类型 = C.代码
WHERE     (C.类型 <> '发票') AND (C.类型 <> '承兑汇票') AND (C.类型 <> '固定资产')


CREATE VIEW dbo.报表_对账单_库存加油
AS
SELECT     A.入账日期, A.对账单号, A.费用项, A.相关人, A.收款金额, A.付款金额, A.金额, A.费用实体类型名称, A.数量, B.日期, A.车辆, A.费用归属, A.起始日期, 
                      A.结束日期,
                          (SELECT     Value
                            FROM          dbo.AD_SimpleParam
                            WHERE      (Name = '报表_对账单_页脚')) AS 报表_页脚
FROM         dbo.报表_对账单_费用项 AS A INNER JOIN
                      dbo.车辆_车辆费用实体 AS B ON A.费用实体 = B.Id
WHERE     (A.费用实体类型名称 <> '车辆产值')

CREATE VIEW [dbo].[视图信息_固定资产折旧_固定资产]
AS
SELECT     A.Id, A.分类, A.购入时间, A.简介, A.使用年限, A.购入金额, A.月折旧额, A.备注, B.编号,
                          (SELECT     SUM(金额) AS Expr1
                            FROM          dbo.财务_费用
                            WHERE      (费用实体 = A.Id)) AS 累计折旧
FROM         dbo.财务_固定资产 AS A INNER JOIN
                      dbo.财务_费用实体 AS B ON A.Id = B.Id
WHERE     (A.状态 = 1)




CREATE VIEW [dbo].[视图费用项_非业务]
AS
SELECT DISTINCT 编号, 名称, 现有费用实体类型, 收, 付, 支出类别, 收入类别, IsActive
FROM         dbo.参数备案_费用项 AS A
WHERE     (现有费用实体类型 LIKE '%21,%') OR
                      (现有费用实体类型 LIKE '%21,%') OR
                      (现有费用实体类型 LIKE '%23,%') OR
                      (现有费用实体类型 LIKE '%24,%') OR
                      (现有费用实体类型 LIKE '%25,%') OR
                      (现有费用实体类型 LIKE '%30,%') OR
                      (现有费用实体类型 LIKE '%31,%') OR
                      (现有费用实体类型 LIKE '%32,%') OR
                      (现有费用实体类型 LIKE '%37,%') OR
                      (现有费用实体类型 LIKE '%50,%')


CREATE VIEW [dbo].[视图费用项_非业务车辆]
AS
SELECT DISTINCT 编号, 名称, 现有费用实体类型, 收, 付, IsActive
FROM         dbo.参数备案_费用项 AS A
WHERE     (现有费用实体类型 LIKE '%12,%') OR
                      (现有费用实体类型 LIKE '%14,%') OR
                      (现有费用实体类型 LIKE '%16,%') OR
                      (现有费用实体类型 LIKE '%17,%') OR
                      (现有费用实体类型 LIKE '%18,%') OR
                      (现有费用实体类型 LIKE '%19,%') OR
                      (现有费用实体类型 LIKE '%20,%')


CREATE VIEW [dbo].[视图费用项_业务]
AS
SELECT     编号, 名称, 收, 付, CASE A.票 WHEN 1 THEN '票,' ELSE '' END + CASE A.箱 WHEN 1 THEN '箱,' ELSE '' END AS 票箱, IsActive, 现有费用实体类型, SeqNo, 票, 箱
FROM         dbo.参数备案_费用项 AS A
WHERE     (现有费用实体类型 LIKE '%10,%')


CREATE VIEW dbo.报表_对账单_委托人
AS
SELECT     入账日期, 对账单号, 费用项, 相关人, 收款金额, 付款金额, 金额, 费用实体类型名称, 货代自编号, 箱号, 箱型, 承运人, 日期, 备注, 起始日期, 结束日期, 
                      费用归属, 车辆, 指运地,
                          (SELECT     Value
                            FROM          dbo.AD_SimpleParam
                            WHERE      (Name = '报表_对账单_页脚')) AS 报表_页脚, 提单号, 船名航次
FROM         dbo.报表_对账单_费用项
WHERE     (费用归属 = 1) AND (收付标志 = 1)

CREATE VIEW [dbo].[视图信息_凭证费用项_动态]
AS
SELECT     编号, 名称, 1 AS 收付标志, 凭证收入类别 AS 凭证费用类别, IsActive
FROM         dbo.参数备案_费用项
WHERE     (凭证收入类别 IS NOT NULL)
UNION ALL
SELECT     编号, 名称, 2 AS 收付标志, 凭证支出类别 AS 凭证费用类别, IsActive
FROM         dbo.参数备案_费用项 AS 参数备案_费用项_2
WHERE     (凭证支出类别 IS NOT NULL)
UNION ALL
SELECT     编号, 名称, 1 AS Expr1, '201' AS Expr2, IsActive
FROM         dbo.参数备案_费用项 AS 参数备案_费用项_1
WHERE     (编号 = '012')
UNION ALL
SELECT     编号, 名称, 1 AS Expr1, '203' AS Expr2, IsActive
FROM         dbo.参数备案_费用项 AS 参数备案_费用项_1
WHERE     (编号 = '012')
UNION ALL
SELECT     编号, 名称, 1 AS Expr1, '204' AS Expr2, IsActive
FROM         dbo.参数备案_费用项 AS 参数备案_费用项_1
WHERE     (编号 = '012')
UNION ALL
SELECT     编号, 名称, 1 AS Expr1, '205' AS Expr2, IsActive
FROM         dbo.参数备案_费用项 AS 参数备案_费用项_1
WHERE     (编号 = '012')
UNION ALL
SELECT     编号, 名称, 2 AS Expr1, '201' AS Expr2, IsActive
FROM         dbo.参数备案_费用项 AS 参数备案_费用项_1
WHERE     (编号 = '012')
UNION ALL
SELECT     编号, 名称, 2 AS Expr1, '203' AS Expr2, IsActive
FROM         dbo.参数备案_费用项 AS 参数备案_费用项_1
WHERE     (编号 = '012')
UNION ALL
SELECT     编号, 名称, 2 AS Expr1, '204' AS Expr2, IsActive
FROM         dbo.参数备案_费用项 AS 参数备案_费用项_1
WHERE     (编号 = '012')
UNION ALL
SELECT     编号, 名称, 2 AS Expr1, '205' AS Expr2, IsActive
FROM         dbo.参数备案_费用项 AS 参数备案_费用项_1
WHERE     (编号 = '012')
UNION ALL
SELECT     编号, 名称, 2 AS Expr1, '207' AS Expr2, IsActive
FROM         dbo.参数备案_费用项 AS 参数备案_费用项_1
WHERE     (编号 = '011')
UNION ALL
SELECT     编号, 名称, 2 AS Expr1, '214' AS Expr2, IsActive
FROM         dbo.参数备案_费用项 AS 参数备案_费用项_1
WHERE     (编号 = '002')


CREATE VIEW dbo.报表_对账单_驾驶员
AS
SELECT     dbo.Concatenate(DISTINCT 提单号) AS 提单号, 对账单号, 相关人, dbo.Concatenate(DISTINCT 任务类别) AS 任务类别, 
                      dbo.Concatenate(DISTINCT 货代自编号) AS 货代自编号, dbo.Concatenate(DISTINCT 箱号) AS 箱号, dbo.Concatenate(DISTINCT 回货箱号) AS 回货箱号, 
                      dbo.Concatenate(DISTINCT 箱型) AS 箱型, 承运人, 驾驶员, 公里, 路线, 日期, 备注, SUM(CASE WHEN 费用项 = 201 AND 
                      任务类别 <> 3 THEN 付款金额 ELSE NULL END) AS 工资, SUM(CASE WHEN 费用项 = 201 AND 任务类别 = 3 THEN 付款金额 ELSE NULL END) 
                      AS 回货工资, SUM(CASE WHEN 费用项 = 202 AND 费用实体类型名称 = '车辆产值' THEN 付款金额 ELSE NULL END) AS 话费补贴, 
                      SUM(CASE WHEN 费用项 = 203 THEN 付款金额 ELSE NULL END) AS 轮胎补贴, SUM(CASE WHEN 费用项 = 205 THEN 付款金额 ELSE NULL END) 
                      AS 定耗油, SUM(CASE WHEN 费用项 = 205 AND 收付标志 = 2 THEN 数量 ELSE NULL END) AS 定耗油数量, 
                      SUM(CASE WHEN 费用项 = 204 THEN 收款金额 ELSE NULL END) AS 实耗油, SUM(CASE WHEN 费用项 = 203 THEN 收款金额 ELSE NULL END) 
                      AS 其它扣款,
                          (SELECT     Value
                            FROM          dbo.AD_SimpleParam
                            WHERE      (Name = '报表_对账单_页脚')) AS 报表_页脚, 车辆, 起始日期, 结束日期
FROM         dbo.报表_对账单_费用项
WHERE     (费用归属 = 3) AND (费用实体类型名称 = '车辆产值')
GROUP BY 对账单号, 相关人, 承运人, 驾驶员, 公里, 路线, 日期, 备注, 车辆, 起始日期, 结束日期

CREATE VIEW [dbo].[视图信息_凭证费用类别]
AS
SELECT     1 AS 收付标志, 代码, 名称, IsActive, 凭证用途分类
FROM         dbo.信息_凭证费用类别
WHERE     (收 = 1)
UNION ALL
SELECT     2 AS 收付标志, 代码, 名称, IsActive, 凭证用途分类
FROM         dbo.信息_凭证费用类别 AS 信息_凭证费用类别_1
WHERE     (付 = 1)




CREATE VIEW dbo.报表_对账单_车主
AS
SELECT     入账日期, 对账单号, 费用项, 相关人, 收款金额, 付款金额, 金额, 费用实体类型名称, 货代自编号, 箱号, 箱型, 驾驶员, 日期, 备注, 起始日期, 结束日期, 
                      费用归属, 车辆, 指运地,
                          (SELECT     Value
                            FROM          dbo.AD_SimpleParam
                            WHERE      (Name = '报表_对账单_页脚')) AS 报表_页脚, 提单号
FROM         dbo.报表_对账单_费用项
WHERE     (费用归属 = 2) AND (费用实体类型名称 = '车辆产值')

CREATE VIEW dbo.视图信息_坏账业务类型_动态
AS
SELECT     A.代码, A.类型, C.编号 AS 费用项编号
FROM         dbo.信息_费用类别 AS A INNER JOIN
                      dbo.信息_凭证费用类别 AS B ON A.收入类别 = B.代码 INNER JOIN
                      dbo.参数备案_费用项 AS C ON B.代码 = C.凭证收入类别 AND C.编号 = '000'
UNION ALL
SELECT     代码, 类型, '002' AS 费用项编号
FROM         dbo.信息_费用类别 AS A
WHERE     (代码 >= 411)
UNION ALL
SELECT     代码, 类型, '004' AS 费用项编号
FROM         dbo.信息_费用类别 AS A
WHERE     (代码 IN (12, 14, 17, 18, 24, 15))

CREATE VIEW [dbo].[视图信息_车辆]
AS
SELECT     Id, 
                      (CASE WHEN 车辆类别 = 1 THEN '自有车' WHEN 车辆类别 = 2 THEN '代管车' WHEN 车辆类别 = 3 THEN '挂靠车' WHEN 车辆类别 = 4 THEN '外协车' END)
                       AS 车辆类别, 简称, 车牌, 车主 AS 车主编号,
                          (SELECT     简称
                            FROM          dbo.参数备案_人员单位
                            WHERE      (编号 = dbo.参数备案_车辆.车主)) AS 车主, 默认驾驶员 AS 默认驾驶员编号,
                          (SELECT     简称
                            FROM          dbo.参数备案_人员单位 AS 参数备案_人员单位_1
                            WHERE      (编号 = dbo.参数备案_车辆.默认驾驶员)) AS 默认驾驶员, 马力, IsActive
FROM         dbo.参数备案_车辆


CREATE VIEW dbo.视图信息_理论值_价格类型
AS
SELECT DISTINCT 类型 AS 编号, CASE WHEN 类型 = 1 THEN '单箱价格' WHEN 类型 = 2 THEN '单价' ELSE NULL END AS 类型
FROM         dbo.参数备案_回货运价

CREATE VIEW dbo.视图查询车辆月报表_费用明细
AS
SELECT     费用实体类型, 源, 金额, 收付标志, 费用项, 费用类别, 费用类型, 小类, 大类, 入账日期, 车辆, 车辆类别, 费用归属, Created, Updated
FROM         dbo.视图查询车辆月报表_费用明细_业务
UNION ALL
SELECT     费用实体类型, 源, 金额, 收付标志, 费用项, 费用类别, 费用类型, 小类, 大类, 入账日期, 车辆, 车辆类别, 费用归属, Created, Updated
FROM         dbo.视图查询车辆月报表_费用明细_车辆管理

CREATE VIEW [dbo].[视图查询_车辆产值_车队]
AS
SELECT     A.车辆类别, C.装卸货地, C.委托人, C.货代自编号, C.箱号, C.箱型, C.任务类别, C.车辆产值, C.驾驶员, B.日期, B.车辆, B.承运人, B.驾驶员 AS 主驾驶员, 
                      B.路线, A.车牌, D.费用实体, D.产值, D.应付, D.扣税, D.额外, D.其他, D.小计
FROM         dbo.参数备案_车辆 AS A INNER JOIN
                      dbo.业务备案_车辆产值 AS B ON A.Id = B.车辆 LEFT OUTER JOIN
                      dbo.视图查询_业务费用_车队 AS D ON B.Id = D.费用实体 LEFT OUTER JOIN
                      dbo.视图查询_车辆产值_信息汇总 AS C ON B.Id = C.车辆产值


CREATE VIEW [dbo].[视图查询_车辆产值_对外支出]
AS
SELECT     A.车辆类别, C.装卸货地, C.委托人, C.货代自编号, C.箱号, C.箱型, C.任务类别, C.车辆产值, C.驾驶员, B.日期, B.车辆, B.承运人, B.驾驶员 AS 主驾驶员, 
                      B.路线, D.开票税, D.路桥费, D.吊机费, D.其他支出, D.实耗油, D.实耗油金额, D.小计, D.任务代付费
FROM         dbo.参数备案_车辆 AS A INNER JOIN
                      dbo.业务备案_车辆产值 AS B ON A.Id = B.车辆 LEFT OUTER JOIN
                      dbo.视图查询_业务费用_对外支出 AS D ON B.Id = D.费用实体 LEFT OUTER JOIN
                      dbo.视图查询_车辆产值_信息汇总 AS C ON B.Id = C.车辆产值
WHERE     (A.车辆类别 = 1) OR
                      (A.车辆类别 = 2)


CREATE VIEW [dbo].[视图查询驾驶员月报表_费用明细]
AS
SELECT     相关人,费用实体类型, 源, 金额, 收付标志, 费用项, 费用类别, 费用类型, 小类, 大类, 入账日期, 车辆, 费用归属
FROM         视图查询驾驶员月报表_费用明细_业务
UNION ALL
SELECT     相关人,费用实体类型, 源, 金额, 收付标志, 费用项, 费用类别, 费用类型, 小类, 大类, 入账日期, 车辆, 费用归属
FROM         视图查询驾驶员月报表_费用明细_车辆管理


CREATE VIEW dbo.视图查询_应收应付明细
AS
SELECT     A.金额, A.相关人, A.收付标志, A.费用项, A.业务类型, A.日期, B.编号 AS 相关号, A.结算期限, B.源, 
                      CASE A.费用项 WHEN '002' THEN '其他' ELSE '业务' END AS 类型, A.备注
FROM         dbo.财务_应收应付款 AS A INNER JOIN
                      dbo.视图信息_应收应付源 AS B ON A.应收应付源 = B.Id
WHERE     (A.费用项 <> '004')
UNION ALL
SELECT     A.金额, A.相关人, A.收付标志, A.费用项, A.业务类型, B.日期, B.凭证号 AS 相关号, NULL AS 结算期限, '非业务专款专用' AS '源', '其他' AS 类型, 
                      A.备注
FROM         dbo.财务_凭证费用明细 AS A INNER JOIN
                      dbo.财务_凭证 AS B ON A.凭证 = B.Id AND B.审核状态 = 1 INNER JOIN
                      dbo.视图费用项_非业务 AS C ON A.费用项 = C.编号
UNION ALL
SELECT     A.金额, A.相关人, A.收付标志, A.费用项, A.业务类型, B.日期, B.凭证号 AS 相关号, NULL AS 结算期限, '业务专款专用' AS '源', '业务' AS 类型, 
                      A.备注
FROM         dbo.财务_凭证费用明细 AS A INNER JOIN
                      dbo.财务_凭证 AS B ON A.凭证 = B.Id AND B.审核状态 = 1 INNER JOIN
                      dbo.视图费用项_业务 AS C ON A.费用项 = C.编号

CREATE VIEW dbo.视图查询_车辆产值_利润分成
AS
SELECT     A.车辆类别, C.装卸货地, C.委托人, C.货代自编号, C.箱号, C.箱型, C.任务类别, C.车辆产值, C.驾驶员, B.日期, B.车辆, B.承运人, B.驾驶员 AS 主驾驶员, B.路线, 
                      D.车队利润, D.驾驶员利润, D.车辆利润, C.相关号, E.运费收, E.运费付, E.卸箱地费收, E.卸箱地费付, E.开票税, E.业务额外, E.业务代付, E.工资, E.话费补贴, 
                      E.轮胎补贴, E.定耗油, E.实耗油, E.路桥费, E.吊机费, E.常规修洗箱费, E.出车其他费
FROM         dbo.参数备案_车辆 AS A INNER JOIN
                      dbo.业务备案_车辆产值 AS B ON A.Id = B.车辆 LEFT OUTER JOIN
                      dbo.视图查询_业务费用_利润分成 AS D ON B.Id = D.费用实体 LEFT OUTER JOIN
                      dbo.视图查询_车辆产值_信息汇总 AS C ON B.Id = C.车辆产值 LEFT OUTER JOIN
                      dbo.视图查询_车辆产值_费用项 AS E ON B.Id = E.费用实体

CREATE VIEW [dbo].[视图查询_车辆产值_自有代管车辆]
AS
SELECT     A.车辆类别, C.装卸货地, C.委托人, C.货代自编号, C.箱号, C.箱型, C.任务类别, C.车辆产值, C.驾驶员, B.日期, B.车辆, B.承运人, B.驾驶员 AS 主驾驶员, 
                      B.路线, D.运费, D.工资, D.话费补贴, D.轮胎补贴, D.定耗油, D.定耗油金额, D.路桥费, D.其他承担, D.额外承担, D.小计, D.任务代付费, B.公里
FROM         dbo.参数备案_车辆 AS A INNER JOIN
                      dbo.业务备案_车辆产值 AS B ON A.Id = B.车辆 LEFT OUTER JOIN
                      dbo.视图查询_业务费用_车辆 AS D ON B.Id = D.费用实体 LEFT OUTER JOIN
                      dbo.视图查询_车辆产值_信息汇总 AS C ON B.Id = C.车辆产值
WHERE     (A.车辆类别 = 1) OR
                      (A.车辆类别 = 2)


CREATE VIEW [dbo].[视图查询_出纳票据本期]
AS
SELECT     B.日期, A.Id, CASE 支票类型 WHEN '1' THEN '现金支票' ELSE '转账支票' END AS 票据类型, A.票据号码, A.金额, A.币制, B.源
FROM         dbo.视图查询_支票 AS A INNER JOIN
                      dbo.视图查询_支票_过程结束 AS B ON A.Id = B.Id
UNION ALL
SELECT     B.日期, A.Id, '承兑汇票' AS 票据类型, A.票据号码, A.金额, 'CNY' AS 币制, CASE B.收付标志 WHEN 1 THEN '收入' ELSE '支出' END AS 源
FROM         dbo.视图查询_承兑汇票 AS A INNER JOIN
                      dbo.视图查询_承兑汇票_凭证收付 AS B ON A.Id = B.承兑汇票
UNION ALL
SELECT     B.返回时间, A.Id, '承兑汇票' AS 票据类型, A.票据号码, A.金额, 'CNY' AS 币制, CASE B.托收贴现 WHEN 1 THEN '托收' ELSE '贴现' END AS 源
FROM         dbo.视图查询_承兑汇票 AS A INNER JOIN
                      dbo.视图查询_承兑汇票_托收贴现 AS B ON A.Id = B.Id INNER JOIN
                      dbo.财务_费用实体 AS C ON C.Id = A.Id
WHERE     (C.Submitted = 1)




CREATE VIEW [dbo].[视图查询_出纳资金当前]
AS
SELECT     SUM(CASE 存取标志 WHEN 1 THEN 金额 ELSE 0 - 金额 END) AS 金额, NULL AS 票据数量, '银行账户:' + B.简称 AS 项目, B.币制
FROM         dbo.视图查询_银行日记帐 AS A INNER JOIN
                      dbo.参数备案_银行账户 AS B ON B.Id = A.银行账户
GROUP BY B.简称, B.币制
UNION ALL
SELECT     SUM(CASE 存取标志 WHEN 2 THEN 金额 ELSE 0 - 金额 END) AS 金额, NULL AS 票据数量, '现金' AS 项目, 币制
FROM         dbo.视图查询_现金日记帐 AS A
GROUP BY 币制
UNION ALL
SELECT     SUM(A.金额) AS 金额, COUNT(*) AS 票据数量, 
                      CASE 托收贴现 WHEN 1 THEN '承兑汇票:在途托收' WHEN 2 THEN '承兑汇票:在途贴现' ELSE '承兑汇票:未使用' END AS 项目, 'CNY' AS Expr1
FROM         dbo.视图查询_承兑汇票 AS A INNER JOIN
                      dbo.财务_费用实体 AS C ON C.Id = A.Id
WHERE     (C.Submitted = 0)
GROUP BY A.托收贴现
UNION ALL
SELECT     SUM(A.金额) AS 金额, COUNT(*) AS 票据数量, '支票:未使用' AS 项目, B.币制
FROM         dbo.财务_支票 AS A INNER JOIN
                      dbo.参数备案_银行账户 AS B ON B.Id = A.银行账户
WHERE     (A.是否作废 = 0) AND (A.Submitted = 0) AND (A.领用方式 IS NULL)
GROUP BY B.币制
UNION ALL
SELECT     SUM(A.金额) AS 金额, COUNT(*) AS 票据数量, '支票:在途' AS 项目, B.币制
FROM         dbo.财务_支票 AS A INNER JOIN
                      dbo.参数备案_银行账户 AS B ON B.Id = A.银行账户
WHERE     (A.是否作废 = 0) AND (A.Submitted = 0) AND (A.领用方式 IS NOT NULL)
GROUP BY B.币制
UNION ALL
SELECT     SUM(CASE 收付标志 WHEN 1 THEN 金额 ELSE 0 - 金额 END) AS 金额, NULL AS 票据数量, '总资金' AS 项目, 币制
FROM         dbo.视图查询_资金日记帐 AS A
GROUP BY 币制




CREATE VIEW dbo.视图查询_费用明细_费用类型_车辆管理
AS
SELECT     F.费用项, F.收付标志, F.相关人, F.金额, F.备注, F.费用实体, F.对账单, F.凭证费用明细, F.车辆, F.数量, F.费用类别, F.费用归属, F.Created, d.日期, 
                      d.车主, d.驾驶员, d.车辆 AS 相关车辆, d.相关人 AS 对外相关人, F.入账日期, F.费用类型, F.凭证号, F.凭证, F.对账单号, F.对账单提交, F.相关号, 
                      F.费用实体类型, F.费用实体类型名称, I.车辆类别, F.收款金额, F.付款金额, F.车辆承担, d.简介, F.Updated
FROM         dbo.视图查询_费用明细 AS F INNER JOIN
                      dbo.车辆_车辆费用实体 AS d ON F.费用实体 = d.Id LEFT OUTER JOIN
                      dbo.参数备案_车辆 AS I ON F.车辆 = I.Id
WHERE     (F.费用类型 = 22)

CREATE VIEW dbo.视图查询交互_易可票未放行
AS
SELECT     A.委托时间, B.预计到港时间, B.到港时间,
                          (SELECT     简称
                            FROM          OPENDATASOURCE ('SQLOLEDB', 
                                                   'Data Source=ykbg8.ticp.net, 8033;Initial Catalog=jkhd2;User ID=sa;Password=qazwsxedc' ).jkhd2.dbo.参数备案_人员单位 AS derivedtbl_1
                            WHERE      (编号 = B.卸箱地)) AS 卸箱地, B.商检查验时间, A.货代自编号, A.箱量, A.合同号, A.品名, B.产地, A.总重量, B.免箱天数, A.提单号,
                          (SELECT     简称
                            FROM          OPENDATASOURCE ('SQLOLEDB', 
                                                   'Data Source=ykbg8.ticp.net, 8033;Initial Catalog=jkhd2;User ID=sa;Password=qazwsxedc' ).jkhd2.dbo.参数备案_人员单位 AS derivedtbl_1_1
                            WHERE      (编号 = A.船公司)) AS 船公司, B.转关标志, A.对下备注, A.件数
FROM         OPENDATASOURCE ('SQLOLEDB', 
                      'Data Source=ykbg8.ticp.net, 8033;Initial Catalog=jkhd2;User ID=sa;Password=qazwsxedc' ).jkhd2.dbo.业务备案_普通票 AS A INNER JOIN
                      OPENDATASOURCE ('SQLOLEDB', 
                      'Data Source=ykbg8.ticp.net, 8033;Initial Catalog=jkhd2;User ID=sa;Password=qazwsxedc' ).jkhd2.dbo.业务备案_进口票 AS B ON A.Id = B.Id
WHERE     (B.放行时间 IS NULL) AND (B.承运人 = '900001')


CREATE VIEW [dbo].[视图查询_库存油罐日记账_行数]
AS
SELECT     ROW_NUMBER() OVER (ORDER BY 日期) AS 当前行数,A.日期, SUM(CASE WHEN b.买卖标志 = 1 THEN B.数量 ELSE 0 END) AS 进量, SUM(CASE WHEN b.买卖标志 <> 1 THEN b.数量 ELSE 0 END) 
                      AS 出量
FROM         dbo.车辆_车辆费用实体 AS A INNER JOIN
                      dbo.车辆_库存加油 AS B ON A.Id = B.Id
GROUP BY A.日期


CREATE VIEW dbo.视图信息_应收应付源
AS
SELECT     Id, 编号, 
                      CASE WHEN 对账单类型 = 11 THEN '对账单_委托人' WHEN 对账单类型 = 12 THEN '对账单_车主' WHEN 对账单类型 = 13 THEN '对账单_对外' WHEN 对账单类型
                       = 14 THEN '对账单_驾驶员' WHEN 对账单类型 = 16 THEN '对账单_车辆管理折旧分摊' WHEN 对账单类型 = 6 THEN '对账单_固定资产折旧' WHEN 对账单类型
                       = 5 THEN '坏账' END AS 源
FROM         dbo.财务_对账单
UNION ALL
SELECT     Id, 凭证号 AS 编号, '凭证' AS 源
FROM         dbo.财务_凭证
UNION ALL
SELECT     Id, 编号, '调节款' AS 源
FROM         dbo.财务_调节款
UNION ALL
SELECT     Id, 编号, '资产入库' AS 源
FROM         dbo.财务_资产入库

CREATE VIEW [dbo].[视图信息_收付款方式]
AS
SELECT     CAST(1 AS int) AS 编号, '现金' AS 名称
UNION ALL
SELECT     CAST(2 AS int) AS 编号, '现金支票' AS 名称
UNION ALL
SELECT     CAST(3 AS int) AS 编号, '转账支票' AS 名称
UNION ALL
SELECT     CAST(4 AS int) AS 编号, '银行承兑汇票' AS 名称
UNION ALL
SELECT     CAST(5 AS int) AS 编号, '银行本票汇票' AS 名称
UNION ALL
SELECT     CAST(6 AS int) AS 编号, '银行收付' AS 名称
UNION ALL
SELECT     CAST(7 AS int) AS 编号, '电汇' AS 名称





CREATE VIEW dbo.视图信息_凭证业务类型_动态
AS
SELECT     1 AS 收付标志, 代码, 类型, 收入类别 AS 凭证费用类别, IsActive
FROM         dbo.信息_费用类别
WHERE     (收入类别 IS NOT NULL) AND (收 = 1)
UNION ALL
SELECT     2 AS 收付标志, 代码, 类型, 支出类别 AS 凭证费用类别, IsActive
FROM         dbo.信息_费用类别 AS 信息_费用类别_1
WHERE     (支出类别 IS NOT NULL) AND (付 = 1)
UNION ALL
SELECT     1 AS 收付标志, 代码, 类型, '103' AS 凭证费用类别, IsActive
FROM         dbo.信息_费用类别 AS 信息_费用类别_1
WHERE     (代码 >= '411') AND (收 = 1)
UNION ALL
SELECT     2 AS 收付标志, 代码, 类型, '104' AS 凭证费用类别, IsActive
FROM         dbo.信息_费用类别 AS 信息_费用类别_1
WHERE     (代码 >= '411') AND (付 = 1)
UNION ALL
SELECT     2 AS 收付标志, 代码, 类型, '206' AS 凭证费用类别, IsActive
FROM         dbo.信息_费用类别 AS A
WHERE     (代码 IN (12, 14, 17, 18, 24))
UNION ALL
SELECT     2 AS 收付标志, 代码, 类型, '207' AS 凭证费用类别, IsActive
FROM         dbo.信息_费用类别 AS A
WHERE     (代码 = 15)

CREATE VIEW [dbo].[视图信息_凭证号]
AS
SELECT     X.Id, P.凭证号, '凭证费用明细' AS 源
FROM         dbo.财务_凭证费用明细 AS X INNER JOIN
                      dbo.财务_凭证 AS P ON X.凭证 = P.Id
UNION ALL
SELECT     X.Id, P.凭证号, '凭证收支明细' AS 源
FROM         dbo.财务_凭证收支明细 AS X INNER JOIN
                      dbo.财务_凭证 AS P ON X.凭证 = P.Id
UNION ALL
SELECT     Id, 凭证号, '凭证' AS 源
FROM         dbo.财务_凭证 AS P




CREATE VIEW dbo.视图查询交互_货代内贸出港_箱信息
AS
SELECT     货代自编号, 提单号, 箱号, 车号, 回货箱号, 装卸货地, 放行时间 AS 开航日期, 提箱时间 AS 装货时间
FROM         OPENDATASOURCE ('SQLOLEDB', 
                      'Data Source=ykbg8.ticp.net, 8033;Initial Catalog=jkhd2;User ID=sa;Password=qazwsxedc' ).jkhd2.dbo.视图查询_车队任务 AS A
WHERE     (业务类型 = '内贸出港')

CREATE VIEW dbo.视图查询月报表_车辆资产
AS
SELECT     CASE WHEN 金额 >= 0 THEN 金额 ELSE NULL END AS 增加, CASE WHEN 金额 < 0 THEN 0 - 金额 ELSE NULL END AS 减少, A.金额, A.相关人, 
                      A.收付标志, A.费用项, A.业务类型, A.日期 AS 入账日期, B.编号 AS 相关号, A.结算期限, B.源, '折旧分摊' AS 类型, C.小类, '车辆管理' AS 大类
FROM         dbo.财务_应收应付款 AS A INNER JOIN
                      dbo.视图信息_应收应付源 AS B ON A.应收应付源 = B.Id INNER JOIN
                      dbo.信息_费用类别 AS C ON A.业务类型 = C.代码
WHERE     (A.费用项 = '004') AND (A.业务类型 <> 24)

CREATE VIEW [dbo].[视图查询_分成表_驾驶员]
AS
SELECT A.车辆类别, C.装卸货地, C.委托人, C.货代自编号, C.箱号, C.箱型, C.任务类别, 
      C.车辆产值, C.驾驶员, B.日期, B.车辆, B.承运人, B.驾驶员 AS 主驾驶员, B.路线, 
      D.相关人, D.工资, D.话费补贴, D.轮胎补贴, D.超节油, D.超节油金额, D.其他收入, 
      D.小计
FROM dbo.参数备案_车辆 AS A INNER JOIN
      dbo.业务备案_车辆产值 AS B ON A.Id = B.车辆 RIGHT OUTER JOIN
      dbo.视图查询_业务费用_驾驶员 AS D ON B.Id = D.费用实体 LEFT OUTER JOIN
      dbo.视图查询_车辆产值_信息汇总 AS C ON B.Id = C.车辆产值


CREATE VIEW dbo.视图查询月报表_承兑汇票
AS
SELECT     托收贴现, '承兑汇票' AS 大类, '承兑汇票' AS 小类, 日期 AS 入账日期, 金额, 收付标志, 票据号码, 所属银行, 来源, 凭证号, 
                      CASE WHEN 收付标志 = 1 THEN 金额 ELSE NULL END AS 增加, CASE WHEN 收付标志 = 2 THEN 金额 ELSE NULL END AS 减少
FROM         dbo.视图查询_承兑汇票_凭证收付

CREATE VIEW dbo.视图查询_货代对账辅助
AS
SELECT     CASE WHEN a.收付标志 = 1 THEN a.金额 ELSE - a.金额 END AS 金额, b.编号 AS 对账单号, c.提单号, c.箱号, (CASE WHEN a.费用项 = 102 AND 
                      c.任务类别 <> 3 THEN 102 WHEN a.费用项 = 102 AND 
                      c.任务类别 = 3 THEN 104 WHEN a.费用项 = 103 THEN 103 WHEN a.费用项 = 111 THEN 111 WHEN a.费用项 = 135 THEN 135 ELSE 136 END) 
                      AS 费用项
FROM         dbo.财务_费用 AS a INNER JOIN
                      dbo.财务_对账单 AS b ON a.对账单 = b.Id INNER JOIN
                      dbo.业务备案_任务 AS c ON a.任务 = c.Id
WHERE     (b.相关人 = '900008')

CREATE VIEW dbo.视图查询月报表_固定资产
AS
SELECT     CASE WHEN 金额 >= 0 THEN 金额 ELSE NULL END AS 增加, CASE WHEN 金额 < 0 THEN 0 - 金额 ELSE NULL END AS 减少, A.金额, A.相关人, 
                      A.收付标志, A.费用项, A.业务类型, A.日期 AS 入账日期, B.编号 AS 相关号, A.结算期限, B.源, '折旧分摊' AS 类型, C.小类, '固定资产' AS 大类
FROM         dbo.财务_应收应付款 AS A INNER JOIN
                      dbo.视图信息_应收应付源 AS B ON A.应收应付源 = B.Id INNER JOIN
                      dbo.信息_费用类别 AS C ON A.业务类型 = C.代码
WHERE     (A.费用项 = '004') AND (A.业务类型 = 24)

CREATE VIEW dbo.视图查询月报表_应收应付
AS
SELECT     CASE WHEN 金额 >= 0 THEN 金额 ELSE NULL END AS 增加, CASE WHEN 金额 < 0 THEN 0 - 金额 ELSE NULL END AS 减少, 金额, 收付标志, 
                      日期 AS 入账日期, 相关号, CASE WHEN 收付标志 = 1 AND 类型 = '业务' THEN '业务应收' WHEN 收付标志 = 2 AND 
                      类型 = '业务' THEN '业务应付' WHEN 收付标志 = 1 AND 类型 = '其他' THEN '其他应收' WHEN 收付标志 = 2 AND 
                      类型 = '其他' THEN '其他应付' ELSE NULL END AS 小类, '应收应付' AS 大类, 费用项, 结算期限, 源, 相关人, 业务类型
FROM         dbo.视图查询_应收应付明细
WHERE     (源 NOT LIKE '%专款专用%') AND (源 NOT LIKE '%未凭证未对账%')

CREATE VIEW dbo.视图查询交互_对账辅助_货代
AS
SELECT     金额, 对账单号, 提单号, 箱号, 费用项
FROM         OPENDATASOURCE ('SQLOLEDB', 
                      'Data Source=ykbg8.ticp.net, 8033;Initial Catalog=jkhd2;User ID=sa;Password=qazwsxedc' ).jkhd2.dbo.视图查询_车队对账辅助 AS derivedtbl_1

CREATE VIEW dbo.视图查询_任务产值_委托人
AS
SELECT     A.车辆类别, C.装卸货地, C.委托人, C.货代自编号, C.箱号, C.箱型, C.任务类别, B.日期, B.车辆, B.承运人, B.驾驶员 AS 主驾驶员, B.路线, D.产值, D.其他承担, 
                      D.委托人额外, D.小计, D.任务代付费, C.指运地, C.提箱地, C.船公司, C.还箱地, C.自备箱, C.箱量, C.提单号, C.备注, C.提箱时间, C.还箱时间, C.装卸货时间, 
                      C.提箱时间要求止, C.还箱时间要求止, C.重量, C.Id AS 任务, D.费用实体, C.车辆产值, E.编号 AS 产值编号
FROM         dbo.财务_费用实体 AS E INNER JOIN
                      dbo.参数备案_车辆 AS A INNER JOIN
                      dbo.业务备案_车辆产值 AS B ON A.Id = B.车辆 ON E.Id = B.Id RIGHT OUTER JOIN
                      dbo.视图查询_业务费用_委托人 AS D RIGHT OUTER JOIN
                      dbo.业务备案_任务 AS C ON D.任务 = C.Id AND D.费用实体 = C.车辆产值 ON B.Id = C.车辆产值

CREATE VIEW dbo.视图查询月报表_资金
AS
SELECT     存取标志, '现金' AS '大类', 币制 AS '小类', 日期 AS 入账日期, 金额, CASE WHEN 存取标志 = 2 THEN 金额 ELSE NULL END AS 增加, 
                      CASE WHEN 存取标志 = 1 THEN 金额 ELSE NULL END AS 减少
FROM         dbo.视图查询_现金日记帐
UNION ALL
SELECT     a.存取标志, '银行存款' AS '大类', b.简称 AS '小类', a.日期 AS 入账日期, a.金额, CASE WHEN 存取标志 = 1 THEN 金额 ELSE NULL END AS 增加, 
                      CASE WHEN 存取标志 = 2 THEN 金额 ELSE NULL END AS 减少
FROM         dbo.视图查询_银行日记帐 AS a INNER JOIN
                      dbo.参数备案_银行账户 AS b ON a.银行账户 = b.Id

CREATE VIEW dbo.视图查询_应收应付明细
AS
SELECT     SUM(A.金额) AS 金额, A.相关人, A.收付标志, A.费用项, A.业务类型, A.日期, B.编号 AS 相关号, A.结算期限, B.源, 
                      CASE A.费用项 WHEN '002' THEN '其他' ELSE '业务' END AS 类型
FROM         dbo.财务_应收应付款 AS A INNER JOIN
                      dbo.视图信息_应收应付源 AS B ON A.应收应付源 = B.Id
WHERE     (A.费用项 <> '004')
GROUP BY A.相关人, A.收付标志, A.费用项, A.业务类型, A.日期, B.编号, A.结算期限, B.源
UNION ALL
SELECT     SUM(A.金额) AS 金额, A.相关人, A.收付标志, A.费用项, A.业务类型, B.日期, B.凭证号 AS 相关号, NULL AS 结算期限, '非业务专款专用' AS '源', 
                      '其他' AS 类型
FROM         dbo.财务_凭证费用明细 AS A INNER JOIN
                      dbo.财务_凭证 AS B ON A.凭证 = B.Id AND B.审核状态 = 1 INNER JOIN
                      dbo.视图费用项_非业务 AS C ON A.费用项 = C.编号
GROUP BY A.相关人, A.收付标志, B.日期, B.凭证号, A.费用项, A.业务类型
UNION ALL
SELECT     SUM(A.金额) AS 金额, A.相关人, A.收付标志, A.费用项, A.业务类型, B.日期, B.凭证号 AS 相关号, NULL AS 结算期限, '业务专款专用' AS '源', 
                      '业务' AS 类型
FROM         dbo.财务_凭证费用明细 AS A INNER JOIN
                      dbo.财务_凭证 AS B ON A.凭证 = B.Id AND B.审核状态 = 1 INNER JOIN
                      dbo.视图费用项_业务 AS C ON A.费用项 = C.编号
GROUP BY A.相关人, A.收付标志, B.日期, B.凭证号, A.费用项, A.业务类型

CREATE VIEW [dbo].[视图查询_应收应付日记帐_行数]
AS
SELECT     ROW_NUMBER() OVER (partition BY 相关人, 收付标志, 费用项
ORDER BY 日期) AS 当前行数, 金额, 相关人, 收付标志, 费用项, 业务类型, 相关号, CASE WHEN 金额 < 0 THEN NULL ELSE 金额 END AS 增, 
CASE WHEN 金额 <= 0 THEN 0 - 金额 ELSE NULL END AS 减, 结算期限, 源, 日期
FROM         dbo.视图查询_应收应付明细
WHERE     源 NOT LIKE '%专款专用%' AND 源 <> '未凭证未对账'






CREATE VIEW dbo.视图查询_应收应付日记帐_行数1
AS
SELECT     ROW_NUMBER() OVER (partition BY 相关人, 收付标志, 类型
ORDER BY 日期) AS 当前行数, 金额, 相关人, 收付标志, 费用项, 类型, 业务类型, 相关号, CASE WHEN 金额 < 0 THEN NULL ELSE 金额 END AS 增, 
CASE WHEN 金额 <= 0 THEN 0 - 金额 ELSE NULL END AS 减, 结算期限, 源, 日期, 备注
FROM         dbo.视图查询_应收应付明细
WHERE     源 NOT LIKE '%专款专用%' AND 源 <> '未凭证未对账'

CREATE VIEW [dbo].[视图查询_应收应付日记帐_余额]
AS
SELECT     TOP (100) PERCENT 当前行数, 金额, 相关人, 收付标志, 费用项, 相关号, 增, 减, 结算期限, 源,
                          (SELECT     SUM(金额) AS 余额
                            FROM          dbo.视图查询_应收应付日记帐_行数 AS t2
                            WHERE      (t1.相关人 = 相关人) AND (t1.收付标志 = 收付标志) AND (t1.费用项 = 费用项) AND (当前行数 <= t1.当前行数)) AS 余额, 日期, 
                      业务类型
FROM         dbo.视图查询_应收应付日记帐_行数 AS t1



CREATE VIEW dbo.视图查询_应收应付日记帐_余额1
AS
SELECT     TOP (100) PERCENT 当前行数, 金额, 相关人, 收付标志, 费用项, 类型, 相关号, 增, 减, 结算期限, 源,
                          (SELECT     SUM(金额) AS 余额
                            FROM          dbo.视图查询_应收应付日记帐_行数1 AS t2
                            WHERE      (t1.相关人 = 相关人) AND (t1.收付标志 = 收付标志) AND (t1.类型 = 类型) AND (当前行数 <= t1.当前行数)) AS 余额, 日期, 业务类型, 
                      备注
FROM         dbo.视图查询_应收应付日记帐_行数1 AS t1


CREATE VIEW [dbo].[视图查询_库存油罐日记账_库存]
AS
SELECT     当前行数, 日期, 进量, 出量,
                          (SELECT     SUM(进量 - 出量) AS Expr1
                            FROM          dbo.视图查询_库存油罐日记账_行数
                            WHERE      (当前行数 <= A.当前行数)) AS 库存
FROM         dbo.视图查询_库存油罐日记账_行数 AS A


CREATE VIEW dbo.视图查询车队月报表_费用明细
AS
SELECT     源, 金额, 收付标志, 小类, 大类, 入账日期, Created, Updated
FROM         dbo.视图查询车队月报表_费用明细_非业务
UNION ALL
SELECT     源, 金额, 收付标志, 小类, 大类, 入账日期, Created, Updated
FROM         dbo.视图查询车队月报表_费用明细_业务
UNION ALL
SELECT     源, 金额, 收付标志, 小类, 大类, 入账日期, Created, Updated
FROM         dbo.视图查询车队月报表_费用明细_车辆管理
UNION ALL
SELECT     源, 金额, 收付标志, 小类, 大类, 入账日期, Created, Updated
FROM         dbo.视图查询车队月报表_费用明细_自有车辆业务
UNION ALL
SELECT     源, 金额, 收付标志, 小类, 大类, 入账日期, Created, Updated
FROM         dbo.视图查询车队月报表_费用明细_自有车辆管理

CREATE VIEW dbo.视图查询驾驶员月报表_费用明细_车辆管理
AS
SELECT     '车辆管理' AS 源, 金额, 收付标志, 费用实体类型名称 AS 小类, '车辆管理' AS 大类, 入账日期, 车辆, 费用项, 相关人, 备注, 费用实体, 对账单, 
                      凭证费用明细, 数量, 费用类别, 费用归属, Created, Updated, 日期, 车主, 驾驶员, 相关车辆, 对外相关人, 费用类型, 凭证号, 凭证, 对账单号, 对账单提交, 
                      相关号, 费用实体类型, 车辆类别, 收款金额, 付款金额
FROM         dbo.视图查询_费用明细_费用类型_车辆管理 AS A
WHERE     (费用归属 = 3) AND (车辆类别 = 1 OR
                      车辆类别 = 2)

CREATE VIEW dbo.视图查询_易可任务
AS
SELECT     B.日期, A.任务类别,
                          (SELECT     简称
                            FROM          dbo.参数备案_人员单位
                            WHERE      (编号 = A.船公司)) AS 船公司,
                          (SELECT     简称
                            FROM          dbo.参数备案_人员单位 AS 参数备案_人员单位_4
                            WHERE      (编号 = A.指运地)) AS 指运地,
                          (SELECT     简称
                            FROM          dbo.参数备案_人员单位 AS 参数备案_人员单位_3
                            WHERE      (编号 = A.装卸货地)) AS 装卸货地,
                          (SELECT     简称
                            FROM          dbo.参数备案_人员单位 AS 参数备案_人员单位_2
                            WHERE      (编号 = A.提箱地)) AS 提箱地,
                          (SELECT     简称
                            FROM          dbo.参数备案_人员单位 AS 参数备案_人员单位_1
                            WHERE      (编号 = A.还箱地)) AS 还箱地, A.货代自编号, A.箱号, A.回货箱号, A.箱型, A.提单号, A.放行时间, A.到港时间
FROM         dbo.业务备案_任务 AS A LEFT OUTER JOIN
                      dbo.业务备案_车辆产值 AS B ON A.车辆产值 = B.Id
WHERE     (A.委托人 = 900008)

CREATE VIEW dbo.视图查询_业务费用_任务
AS
SELECT     D.日期, D.车辆 AS 承运车辆, D.承运人, D.驾驶员, D.路线, I.车辆类别, A.Submitted AS 完全标志, F.收付标志, F.费用项, F.相关人, F.收款金额, 
                      F.付款金额, F.费用类型, F.费用类别, F.凭证号, F.备注, F.车辆, F.金额, F.费用实体, F.对账单, F.凭证费用明细, F.任务, F.费用信息, F.数量, F.凭证, 
                      F.对账单号, F.对账单提交, F.入账日期, F.费用归属, F.相关号, F.费用实体类型, F.Created, F.任务类别, F.车辆承担, E.委托人, E.装卸货地, E.货代自编号, 
                      E.箱号, E.箱型, E.车辆产值, E.回货箱号, E.船名航次, E.指运地, E.提箱地, E.还箱地, E.重量, E.提单号
FROM         dbo.业务备案_任务 AS E RIGHT OUTER JOIN
                      dbo.视图查询_费用明细 AS F LEFT OUTER JOIN
                      dbo.参数备案_车辆 AS I ON F.车辆 = I.Id LEFT OUTER JOIN
                      dbo.业务备案_车辆产值 AS D ON F.费用实体 = D.Id ON E.Id = F.任务 LEFT OUTER JOIN
                      dbo.财务_费用信息 AS A ON F.费用信息 = A.Id
WHERE     (F.费用类型 = 21)

CREATE VIEW dbo.视图信息_费用实体_日期
AS
SELECT     Id, 日期
FROM         dbo.车辆_车辆费用实体
UNION ALL
SELECT     Id, 日期
FROM         dbo.业务备案_车辆产值

CREATE VIEW dbo.报表_工资单
AS
SELECT     b.编号 AS 工资单号, a.员工, a.简介, a.备注, ISNULL(a.基本工资, 0) AS 基本工资, ISNULL(a.餐费, 0) AS 餐费, ISNULL(a.通讯费, 0) AS 通讯费, 
                      ISNULL(a.福利, 0) AS 福利, ISNULL(a.补助, 0) AS 补助, ISNULL(a.违纪扣款, 0) AS 违纪扣款, ISNULL(a.养老扣款, 0) AS 养老扣款, ISNULL(a.医疗扣款, 0) 
                      AS 医疗扣款, ISNULL(a.失业扣款, 0) AS 失业扣款, ISNULL(a.其他扣款, 0) AS 其他扣款, a.日期
FROM         dbo.财务_工资单 AS a INNER JOIN
                      dbo.财务_费用实体 AS b ON a.Id = b.Id

CREATE VIEW dbo.报表_凭证
AS
SELECT     凭证类别, 相关人 AS 相关人编号, 审核状态, 收支状态, 是否作废, 备注, 摘要, 会计金额, 审核人 AS 审核人编号, 会计 AS 会计编号, 出纳 AS 出纳编号, 
                      币制 AS 币制编号, 数额, dbo.ConvertToChineseMoney(数额) AS 大写金额, 凭证号, 日期,
                          (SELECT     Value
                            FROM          dbo.AD_SimpleParam
                            WHERE      (Name = '凭证归属')) AS 凭证归属
FROM         dbo.财务_凭证

CREATE VIEW [dbo].[报表_凭证费用明细]
AS
SELECT     a.相关人 AS 相关人编号, a.金额, a.费用项 AS 费用项编号, b.凭证号, b.日期, (CASE WHEN 收付标志 = 1 THEN a.金额 END) AS 收款金额, 
                      (CASE WHEN 收付标志 = 2 THEN a.金额 END) AS 付款金额, a.业务类型, a.凭证费用类别, a.备注, a.收付标志
FROM         dbo.财务_凭证费用明细 AS a INNER JOIN
                      dbo.财务_凭证 AS b ON a.凭证 = b.Id



CREATE VIEW [dbo].[报表_凭证收支明细]
AS
SELECT     a.收付款方式, a.承兑期限, a.票据号码, a.银行账户, (CASE WHEN 收付标志 = 1 THEN 金额 END) AS 收款金额, 
                      (CASE WHEN 收付标志 = 2 THEN 金额 END) AS 付款金额, a.付款人, a.出票银行, b.凭证号
FROM         dbo.财务_凭证收支明细 AS a LEFT OUTER JOIN
                      dbo.财务_凭证 AS b ON a.凭证 = b.Id



CREATE VIEW [dbo].[视图_未处理费用信息]
AS
SELECT     费用信息
FROM         dbo.财务_费用
WHERE     (费用信息 IS NOT NULL) AND (对账单 IS NULL) AND (凭证费用明细 IS NULL)
GROUP BY 费用信息




CREATE VIEW dbo.视图查询_资金票据_应收应付当前
AS
SELECT     相关人, 收付标志, 类型, SUM(金额) AS 拟收拟付, SUM(CASE WHEN 源 = '未凭证未对账' THEN 0 ELSE 金额 END) AS 应收应付, 
                      SUM(CASE WHEN 结算期限 <= getdate() THEN 金额 ELSE 0 END) AS 结算到期, DATEADD(dd, - 390, GETDATE()) AS 结算期限
FROM         dbo.视图查询_应收应付明细 AS a
WHERE     (源 NOT LIKE '%专款专用%')
GROUP BY 相关人, 收付标志, 类型

CREATE VIEW dbo.视图查询车队月报表_费用明细_车辆管理
AS
SELECT     '车辆管理' AS 源, CASE WHEN 收付标志 = 2 THEN 金额 ELSE - 金额 END AS 金额, 2 AS 收付标志, 费用实体类型名称 AS 小类, '车队车辆管理' AS 大类, 
                      费用项, 相关人, 备注, 费用实体, 对账单, 凭证费用明细, 车辆, 数量, 费用类别, 费用归属, Created, Updated, 日期, 车主, 驾驶员, 相关车辆, 对外相关人, 
                      入账日期, 费用类型, 凭证号, 凭证, 对账单号, 对账单提交, 相关号, 费用实体类型, 费用实体类型名称, 车辆类别, 收款金额, 付款金额
FROM         dbo.视图查询_费用明细_费用类型_车辆管理 AS A
WHERE     (车辆类别 <> 1) OR
                      (车辆类别 IS NULL)
UNION ALL
SELECT     '车辆管理' AS 源, CASE WHEN 收付标志 = 2 THEN 金额 ELSE - 金额 END AS 金额, 2 AS 收付标志, 费用实体类型名称 AS 小类, '车队车辆管理' AS 大类, 
                      费用项, 相关人, 备注, 费用实体, 对账单, 凭证费用明细, 车辆, 数量, 费用类别, 费用归属, Created, Updated, 日期, 车主, 驾驶员, 相关车辆, 对外相关人, 
                      入账日期, 费用类型, 凭证号, 凭证, 对账单号, 对账单提交, 相关号, 费用实体类型, 费用实体类型名称, 车辆类别, 收款金额, 付款金额
FROM         dbo.视图查询_费用明细_费用类型_车辆管理 AS A
WHERE     (车辆类别 = 1) AND (费用类别 = 18) AND (费用项 = 386)

CREATE VIEW dbo.视图查询交互_货代任务
AS
SELECT     委托人, 任务类别, 货代自编号, 提单号, 船公司, 箱量, 提箱地, 指运地, 装卸货地, 还箱地, 货代提箱时间要求止, 货代还箱时间要求止, 箱号, 箱型, 
                      委托时间, 回货箱号, 到港时间, CASE WHEN 商检查验 IS NULL THEN NULL ELSE 商检查验时间 END AS 商检查验时间, 转关标志, 提箱时间, 还箱时间, 
                      放行时间, 船名航次
FROM         OPENDATASOURCE ('SQLOLEDB', 
                      'Data Source=ykbg8.ticp.net, 8033;Initial Catalog=jkhd2;User ID=sa;Password=qazwsxedc' ).jkhd2.dbo.视图查询_车队任务 AS A
WHERE     (任务类别 = '拆') AND ((箱号 + 提单号) NOT IN
                          (SELECT     箱号提单号Uniqe AS Expr1
                            FROM          dbo.业务备案_任务)) AND (放行时间 IS NOT NULL) OR
                      (任务类别 = '拆') AND ((箱号 + 提单号) NOT IN
                          (SELECT     箱号提单号Uniqe AS Expr1
                            FROM          dbo.业务备案_任务 AS 业务备案_任务_1)) AND (商检查验时间 IS NOT NULL)

CREATE VIEW dbo.视图查询车队月报表_费用明细_自有车辆管理
AS
SELECT     '自有车辆管理' AS 源, CASE WHEN 收付标志 = 2 THEN 金额 ELSE - 金额 END AS 金额, 2 AS 收付标志, 费用实体类型名称 AS 小类, 
                      '自有车辆管理' AS 大类, 费用项, 相关人, 备注, 费用实体, 对账单, 凭证费用明细, 车辆, 数量, 费用类别, 费用归属, Created, Updated, 日期, 车主, 驾驶员,
                       相关车辆, 对外相关人, 入账日期, 费用类型, 凭证号, 凭证, 对账单号, 对账单提交, 相关号, 费用实体类型, 费用实体类型名称, 车辆类别, 收款金额, 
                      付款金额
FROM         dbo.视图查询_费用明细_费用类型_车辆管理 AS A
WHERE     (车辆承担 = 1)

CREATE VIEW dbo.视图查询月报表_费用明细
AS
SELECT     大类, 小类, 入账日期, 金额, 收付标志, 增加, 减少, CASE WHEN 小类 IN ('业务应付', '其他应付') THEN '负债' ELSE '资产' END AS 类别
FROM         dbo.视图查询月报表_承兑汇票
UNION ALL
SELECT     大类, 小类, 入账日期, 金额, 存取标志 AS 收付标志, 增加, 减少, CASE WHEN 小类 IN ('业务应付', '其他应付') 
                      THEN '负债' ELSE '资产' END AS 类别
FROM         dbo.视图查询月报表_资金
UNION ALL
SELECT     大类, 小类, 入账日期, 金额, 收付标志, 增加, 减少, CASE WHEN 小类 IN ('业务应付', '其他应付') THEN '负债' ELSE '资产' END AS 类别
FROM         dbo.视图查询月报表_应收应付
UNION ALL
SELECT     大类, 小类, 入账日期, 金额, 收付标志, 增加, 减少, CASE WHEN 小类 IN ('业务应付', '其他应付') THEN '负债' ELSE '资产' END AS 类别
FROM         dbo.视图查询月报表_车辆资产
UNION ALL
SELECT     大类, 小类, 入账日期, 金额, 收付标志, 增加, 减少, CASE WHEN 小类 IN ('业务应付', '其他应付') THEN '负债' ELSE '资产' END AS 类别
FROM         dbo.视图查询月报表_固定资产

CREATE VIEW [dbo].[视图查询_承兑汇票_凭证收付]
AS
SELECT     TOP (100) PERCENT B.Id AS 凭证收支明细, B.收付标志, C.票据号码, C.Id AS 承兑汇票, B.Id, B.凭证, A.凭证号, A.摘要 AS 凭证摘要, A.日期, 
                      C.出票银行 AS 所属银行, C.付款人 AS 来源, B.票据号码 AS 票号, C.金额, C.托收贴现, C.承兑期限 AS 到期时间, C.返回时间
FROM         dbo.财务_凭证 AS A INNER JOIN
                      dbo.财务_凭证收支明细 AS B ON A.Id = B.凭证 INNER JOIN
                      dbo.财务_承兑汇票 AS C ON B.票据号码 = C.票据号码 AND B.收付款方式 = 4
WHERE     (A.收支状态 = 1)



CREATE VIEW [dbo].[视图查询_承兑汇票]
AS
SELECT     C.Id, C.票据号码, C.出票银行, C.承兑期限, C.付款人, C.托收贴现, C.备注, C.摘要, C.金额, A.Submitted, C.返回时间
FROM         dbo.财务_承兑汇票 AS C INNER JOIN
                      dbo.财务_费用实体 AS A ON C.Id = A.Id




CREATE VIEW dbo.视图查询_车辆产值_信息汇总
AS
SELECT     (SELECT     TOP (1) 指运地
                       FROM          dbo.业务备案_任务
                       WHERE      (车辆产值 = C.Id)
                       ORDER BY 任务类别) AS 指运地, dbo.Concatenate(DISTINCT A.装卸货地) AS 装卸货地, dbo.Concatenate(DISTINCT A.委托人) AS 委托人, 
                      dbo.Concatenate(DISTINCT A.货代自编号) AS 货代自编号, dbo.Concatenate(DISTINCT A.箱号) AS 箱号, dbo.Concatenate(DISTINCT A.箱型) AS 箱型, 
                      dbo.Concatenate(DISTINCT A.任务类别) AS 任务类别, C.Id AS 车辆产值, dbo.Concatenate(DISTINCT CASE WHEN b.费用归属 = 3 THEN b.相关人 END) 
                      AS 驾驶员, C.Id, D.编号 AS 相关号
FROM         dbo.业务备案_车辆产值 AS C INNER JOIN
                      dbo.财务_费用实体 AS D ON C.Id = D.Id LEFT OUTER JOIN
                      dbo.财务_费用 AS B ON D.Id = B.费用实体 AND C.Id = B.费用实体 LEFT OUTER JOIN
                      dbo.业务备案_任务 AS A ON C.Id = A.车辆产值
GROUP BY C.Id, D.编号

CREATE VIEW [dbo].[视图财务_可支付票据]
AS
SELECT     '承兑汇票' AS 源, C.Id, C.票据号码
FROM         dbo.财务_承兑汇票 AS C INNER JOIN
                      dbo.财务_费用实体 AS A ON C.Id = A.Id
WHERE     (C.托收贴现 IS NULL) AND (A.Submitted = 0)
UNION ALL
SELECT     CASE 支票类型 WHEN '1' THEN '现金支票' ELSE '转账支票' END AS 源, Id, 票据号码
FROM         dbo.财务_支票
WHERE     (是否作废 = 0) AND (Submitted = 0) AND (领用方式 IS NOT NULL)


CREATE VIEW [dbo].[视图查询_车辆产值_费用信息]
AS
SELECT     a.Id, a.费用类型, a.费用项, a.收付标志, a.相关人, a.金额, (CASE WHEN a.收付标志 = 1 THEN a.金额 ELSE 0 END) AS 收款金额, 
                      (CASE WHEN a.收付标志 = 2 THEN a.金额 ELSE 0 END) AS 付款金额, a.费用实体, a.对账单, a.凭证费用明细, a.车辆, a.任务, a.费用信息, a.数量, 
                      a.费用类别, a.费用归属, b.完全标志付, b.Submitted, b.车辆产值, d.凭证号, e.编号 AS 对账单号, a.备注
FROM         dbo.财务_费用 AS a LEFT OUTER JOIN
                      dbo.财务_费用信息 AS b ON a.费用信息 = b.Id LEFT OUTER JOIN
                      dbo.财务_凭证费用明细 AS c ON a.凭证费用明细 = c.Id LEFT OUTER JOIN
                      dbo.财务_凭证 AS d ON c.凭证 = d.Id LEFT OUTER JOIN
                      dbo.财务_对账单 AS e ON a.对账单 = e.Id


CREATE VIEW dbo.视图_应收应付凭证Id
AS
SELECT     b.Id, b.凭证号
FROM         dbo.财务_凭证费用明细 AS a INNER JOIN
                      dbo.财务_凭证 AS b ON a.凭证 = b.Id
WHERE     (a.费用项 IN ('012', '002', '000', '001', '011', '004'))

CREATE VIEW dbo.视图查询车辆月报表_费用明细_车辆管理
AS
SELECT     '车辆管理' AS 源, 金额, 收付标志, 费用实体类型名称 AS 小类, '车辆管理' AS 大类, 入账日期, 车辆, 费用项, 相关人, 备注, 费用实体, 对账单, 
                      凭证费用明细, 数量, 费用类别, 费用归属, Created, Updated, 日期, 车主, 驾驶员, 相关车辆, 对外相关人, 费用类型, 凭证号, 凭证, 对账单号, 对账单提交, 
                      相关号, 费用实体类型, 车辆类别, 收款金额, 付款金额
FROM         dbo.视图查询_费用明细_费用类型_车辆管理 AS A
WHERE     (费用归属 = 2) AND (车辆类别 = 1 OR
                      车辆类别 = 2)
UNION ALL
SELECT     '车辆管理' AS 源, 金额, CASE 收付标志 WHEN 1 THEN 2 ELSE 1 END AS 收付标志, 费用实体类型名称 AS 小类, '车辆管理' AS 大类, 入账日期, 车辆, 
                      费用项, 相关人, 备注, 费用实体, 对账单, 凭证费用明细, 数量, 费用类别, 费用归属, Created, Updated, 日期, 车主, 驾驶员, 相关车辆, 对外相关人, 
                      费用类型, 凭证号, 凭证, 对账单号, 对账单提交, 相关号, 费用实体类型, 车辆类别, 收款金额, 付款金额
FROM         dbo.视图查询_费用明细_费用类型_车辆管理 AS A
WHERE     (车辆承担 = 1)

CREATE VIEW dbo.视图查询_调油表明细
AS
SELECT     a.费用实体, c.车辆类别, a.费用项, a.收付标志, a.金额, (CASE WHEN a.收付标志 = 1 THEN a.金额 ELSE NULL END) AS 收款金额, 
                      (CASE WHEN a.收付标志 = 2 THEN a.金额 ELSE NULL END) AS 付款金额, a.备注, a.费用归属, a.数量, f.编号 AS 相关号, f.费用实体类型, 
                      CASE WHEN f.费用实体类型 = 10 THEN b.日期 ELSE e.日期 END AS 日期, a.相关人, a.车辆, d.任务类别, d.箱号, d.箱型, d.货代自编号, d.委托人, 
                      d.装卸货地, e.相关人 AS 加油站, c.车主, d.驾驶员, p.凭证号, g.编号 AS 对账单号, a.车辆承担, CASE WHEN a.对账单 IS NOT NULL AND 
                      G.Submitted = 1 THEN G.关账日期 WHEN a.对账单 IS NULL AND a.凭证费用明细 IS NOT NULL AND P.审核状态 = 1 THEN P.日期 ELSE NULL 
                      END AS 入账日期
FROM         dbo.财务_对账单 AS g RIGHT OUTER JOIN
                      dbo.财务_费用 AS a INNER JOIN
                      dbo.财务_费用实体 AS f ON a.费用实体 = f.Id ON g.Id = a.对账单 LEFT OUTER JOIN
                      dbo.财务_凭证费用明细 AS h LEFT OUTER JOIN
                      dbo.财务_凭证 AS p ON h.凭证 = p.Id ON a.凭证费用明细 = h.Id LEFT OUTER JOIN
                      dbo.视图查询_车辆产值_信息汇总 AS d RIGHT OUTER JOIN
                      dbo.业务备案_车辆产值 AS b ON d.车辆产值 = b.Id ON a.费用实体 = b.Id LEFT OUTER JOIN
                      dbo.车辆_车辆费用实体 AS e ON a.费用实体 = e.Id LEFT OUTER JOIN
                      dbo.参数备案_车辆 AS c ON a.车辆 = c.Id
WHERE     (a.费用项 = 204) OR
                      (a.费用项 = 205)

CREATE VIEW dbo.视图查询_费用明细
AS
SELECT     a.收付标志, a.费用项, a.相关人, (CASE WHEN a.收付标志 = 1 THEN a.金额 ELSE NULL END) AS 收款金额, 
                      (CASE WHEN a.收付标志 = 2 THEN a.金额 ELSE NULL END) AS 付款金额, a.费用类型, a.费用类别, e.凭证号, a.备注, a.车辆, a.金额, a.费用实体, 
                      a.对账单, a.凭证费用明细, a.任务, a.费用信息, a.数量, d.凭证, f.编号 AS 对账单号, f.Submitted AS 对账单提交, CASE WHEN g.费用实体类型 = 16 AND 
                      g.Submitted = 1 THEN i.日期 WHEN g.费用实体类型 <> 16 AND a.对账单 IS NOT NULL AND 
                      f.Submitted = 1 THEN f.关账日期 WHEN g.费用实体类型 <> 16 AND a.对账单 IS NULL AND a.凭证费用明细 IS NOT NULL AND 
                      e.审核状态 = 1 THEN e.日期 ELSE NULL END AS 入账日期, a.费用归属, G.编号 AS 相关号, G.费用实体类型, a.Created, a.费用实体类型编号, 
                      a.任务类别, H.类型 AS 费用实体类型名称, a.车辆承担, a.Updated, f.起始日期, f.结束日期, f.收付标志 AS 对账单收付标志
FROM         dbo.财务_费用 AS a INNER JOIN
                      dbo.财务_费用实体 AS G ON a.费用实体 = G.Id INNER JOIN
                      dbo.信息_费用类别 AS H ON G.费用实体类型 = H.代码 LEFT OUTER JOIN
                      dbo.视图信息_费用实体_日期 AS i ON a.费用实体 = i.Id LEFT OUTER JOIN
                      dbo.财务_凭证费用明细 AS d ON a.凭证费用明细 = d.Id LEFT OUTER JOIN
                      dbo.财务_凭证 AS e ON d.凭证 = e.Id LEFT OUTER JOIN
                      dbo.财务_对账单 AS f ON a.对账单 = f.Id

CREATE VIEW dbo.视图查询_车辆产值_费用项
AS
SELECT     费用实体, SUM(CASE WHEN 费用项 = 102 THEN 收款金额 ELSE 0 END) AS 运费收, SUM(CASE WHEN 费用项 = 102 THEN 付款金额 ELSE 0 END) 
                      AS 运费付, SUM(CASE WHEN 费用项 = 103 THEN 收款金额 ELSE 0 END) AS 卸箱地费收, SUM(CASE WHEN 费用项 = 103 THEN 付款金额 ELSE 0 END) 
                      AS 卸箱地费付, SUM(CASE WHEN 费用项 = 335 THEN 付款金额 ELSE 0 END) AS 开票税, 
                      SUM(CASE WHEN 费用类别 = 322 THEN 收款金额 ELSE 0 END - CASE WHEN 费用类别 = 322 THEN 付款金额 ELSE 0 END) AS 业务额外, 
                      SUM(CASE WHEN 费用类别 = 323 AND 费用归属 = 1 THEN 付款金额 ELSE 0 END) AS 业务代付, SUM(CASE WHEN 费用项 = 201 AND 
                      费用归属 = 3 THEN 付款金额 ELSE 0 END) AS 工资, SUM(CASE WHEN 费用项 = 202 AND 费用归属 = 3 THEN 付款金额 ELSE 0 END) AS 话费补贴, 
                      SUM(CASE WHEN 费用项 = 203 AND 费用归属 = 3 THEN 付款金额 ELSE 0 END) AS 轮胎补贴, SUM(CASE WHEN 费用项 = 205 AND 
                      费用归属 = 3 THEN 付款金额 ELSE 0 END) AS 定耗油, SUM(CASE WHEN 费用项 = 204 AND 费用归属 = 4 THEN 付款金额 ELSE 0 END) AS 实耗油, 
                      SUM(CASE WHEN 费用项 = 211 THEN 付款金额 ELSE 0 END) AS 路桥费, SUM(CASE WHEN 费用项 = 111 THEN 付款金额 ELSE 0 END) AS 吊机费, 
                      SUM(CASE WHEN 费用项 = 135 THEN 付款金额 ELSE 0 END) AS 常规修洗箱费, SUM(CASE WHEN 费用项 = 219 AND 
                      费用归属 = 4 THEN 付款金额 ELSE 0 END) AS 出车其他费
FROM         dbo.视图查询_费用明细
WHERE     (费用实体类型名称 = '车辆产值')
GROUP BY 费用实体

CREATE VIEW dbo.视图查询_费用明细_费用类型_非业务
AS
SELECT     收付标志, 费用项, 相关人, 备注, 对账单, 凭证费用明细, 入账日期, 费用实体, 金额, 费用类别, 对账单号, 对账单提交, 凭证, 凭证号, 费用实体类型, 
                      Created, 相关号, 费用类型, 收款金额, 付款金额, Updated
FROM         dbo.视图查询_费用明细 AS A
WHERE     (费用类型 = 11)

CREATE VIEW [dbo].[视图查询_承兑汇票_托收贴现]
AS
SELECT     托收贴现, Id, 票据号码, 出去时间, 经办人, 出去经手人, 返回时间, 返回方式, 入款账户, 返回经手人, 返回金额
FROM         dbo.财务_承兑汇票 AS C
WHERE     (托收贴现 IS NOT NULL)




CREATE VIEW [dbo].[视图查询_费用明细_费用类型_非业务_投资]
AS
SELECT     A.入账日期, A.相关人, CASE WHEN (收付标志 = 1 AND 费用项 = 321) OR
                      (收付标志 = 2 AND 费用项 = 322) THEN '他人投资公司' ELSE '公司投资他人' END AS 类型, CASE 费用项 WHEN 321 THEN 金额 ELSE NULL 
                      END AS 投资金额, CASE 费用项 WHEN 322 THEN 金额 ELSE NULL END AS 撤资金额, A.备注, A.相关号, A.凭证号, B.简介,
                          (SELECT     dbo.Concatenate(DISTINCT 收付款方式) AS 收付款方式
                            FROM          dbo.财务_凭证收支明细 AS X
                            WHERE      (凭证 = A.凭证)) AS 收付款方式
FROM         dbo.视图查询_费用明细_费用类型_非业务 AS A INNER JOIN
                      dbo.财务_投资 AS B ON A.费用实体 = B.Id
WHERE     (A.费用实体类型 = 30)


CREATE VIEW dbo.视图查询_费用明细_费用类型_业务
AS
SELECT     D.日期, D.车辆 AS 承运车辆, D.承运人, D.驾驶员, D.路线, H.装卸货地, H.委托人, H.货代自编号, H.箱号, H.箱型, H.车辆产值, 
                      H.任务类别 AS 趟任务类别, I.车辆类别, A.Submitted AS 完全标志, F.收付标志, F.费用项, F.相关人, F.收款金额, F.付款金额, F.费用类型, F.费用类别, 
                      F.凭证号, F.备注, F.车辆, F.金额, F.费用实体, F.对账单, F.凭证费用明细, F.任务, F.费用信息, F.数量, F.凭证, F.对账单号, F.对账单提交, F.入账日期, 
                      F.费用归属, F.相关号, F.费用实体类型, F.Created, F.任务类别, F.车辆承担, F.Updated
FROM         dbo.业务备案_任务 AS E RIGHT OUTER JOIN
                      dbo.视图查询_费用明细 AS F LEFT OUTER JOIN
                      dbo.参数备案_车辆 AS I ON F.车辆 = I.Id LEFT OUTER JOIN
                      dbo.业务备案_车辆产值 AS D INNER JOIN
                      dbo.视图查询_车辆产值_信息汇总 AS H ON D.Id = H.车辆产值 ON F.费用实体 = D.Id ON E.Id = F.任务 LEFT OUTER JOIN
                      dbo.财务_费用信息 AS A ON F.费用信息 = A.Id
WHERE     (F.费用类型 = 21)

