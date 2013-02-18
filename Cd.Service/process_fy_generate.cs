using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;
using System.Reflection;
using Feng;
using Feng.Utils;
using Feng.Windows.Forms;
using Feng.Grid;
using Cd.Model;
using Hd.Model;

namespace Cd.Service
{
    public class process_fy_generate
    {
        public static void 批量生成费用(IRepository rep, 车辆产值 产值, IEnumerable 任务s, string 费用项编号, 收付标志? 收付标志, IList<业务费用理论值> llzs)
        {
            车队合同 wtrht = CdDataBuffer.Instance.Get车队合同(rep);
            if (wtrht != null)
            {
                foreach (车队合同费用项 htfyx in wtrht.合同费用项)
                {
                    // 如果指定费用项，则只生成此费用项下的费用
                    if (!string.IsNullOrEmpty(费用项编号)
                        && htfyx.费用项编号 != 费用项编号)
                    {
                        continue;
                    }

                    批量生成费用(rep, 产值, 任务s, htfyx, llzs, !string.IsNullOrEmpty(费用项编号));
                }
            }
        }


        private static void 批量生成费用(IRepository rep, 车辆产值 产值, IEnumerable 任务s, 车队合同费用项 htfyx, IList<业务费用理论值> llzs, bool mustGenerateFy)
        {
            费用项 fyx = EntityBufferCollection.Instance.Get<费用项>(htfyx.费用项编号);
            if (fyx.箱)
            {
                foreach (任务 箱 in 任务s)
                {
                    GenerateFy(rep, 产值, 箱, htfyx, llzs, mustGenerateFy);
                }
            }
            else if (fyx.票)
            {
                GenerateFy(rep, 产值, null, htfyx, llzs, mustGenerateFy);
            }
        }

        private static void GenerateFy(IRepository rep, 车辆产值 产值, 任务 任务, 车队合同费用项 htfyx, IList<业务费用理论值> llzs, bool mustGenerateFy)
        {
            string 相关人 = Get相关人(rep, 产值, 任务, htfyx);
            decimal? 金额 = Get理论值(rep, 产值, 任务, htfyx);
            if (金额.HasValue && 金额.Value == decimal.MinValue)
            {
                return;
            }

            bool llrHaveGenerated = false;
            foreach (业务费用理论值 i in llzs)
            {
                bool b = i.费用项编号 == htfyx.费用项编号
                    && i.相关人编号 == 相关人;
                if (b && 任务 != null)
                {
                    b &= i.任务ID == 任务.ID;
                }
                if (b)
                {
                    llrHaveGenerated = true;
                    break;
                }
            }

            业务费用理论值 ywfylrz = null;
            if (!llrHaveGenerated)
            {
                if (金额.HasValue)
                {
                    ywfylrz = new 业务费用理论值();
                    ywfylrz.费用实体 = 产值;
                    ywfylrz.费用项编号 = htfyx.费用项编号;                    
                    ywfylrz.票 = 产值;
                    ywfylrz.收付标志 = htfyx.收付标志;
                    ywfylrz.相关人编号 = Get相关人(rep, 产值, 任务, htfyx);
                    ywfylrz.车辆编号 = 产值.车辆编号;
                    ywfylrz.费用归属 = (htfyx as 车队合同费用项).费用归属;
                    //ywfylrz.金额 = 金额.Value;
                    ProcessFywithSl(ywfylrz, 金额.Value);

                    if (任务 != null)
                    {
                        ywfylrz.任务 = 任务;
                        ywfylrz.任务ID = 任务.ID;
                    }

                    (new HdBaseDao<业务费用理论值>()).Save(rep, ywfylrz);
                    llzs.Add(ywfylrz);
                }
            }

            if (htfyx.是否生成实际费用)
            {
                bool generateFy = false;
                // 在外层，判断理论值是否生成过
                if (!mustGenerateFy)
                {
                    if (htfyx.是否空值全部生成)
                    {
                        // 金额为Null的时候判断时候生成过，没生成过也要生成
                        if (!金额.HasValue)
                        {
                            bool fyHaveGenerated = false;
                            foreach (业务费用 i in 产值.费用)
                            {
                                bool b = i.费用项编号 == htfyx.费用项编号
                                   && i.费用归属 == htfyx.费用归属;
                                if (b && 任务 != null)
                                {
                                    b &= i.任务.ID == 任务.ID;
                                }
                                if (b)
                                {
                                    fyHaveGenerated = true;
                                    break;
                                }
                            }
                            generateFy = !fyHaveGenerated;
                        }
                    }
                    
                    if (!generateFy)
                    {
                        // 只有理论值未生成过，且有理论值的情况下，准备生成费用
                        if (!llrHaveGenerated && ywfylrz != null)
                        {
                            // 如果理论值未生成过，要检查是否要生成费用
                            bool fyHaveGenerated = false;
                            foreach (业务费用 i in 产值.费用)
                            {
                                bool b = i.费用项编号 == htfyx.费用项编号
                                   && i.费用归属 == htfyx.费用归属;
                                if (b && 任务 != null)
                                {
                                    b &= i.任务.ID == 任务.ID;
                                }
                                if (b)
                                {
                                    fyHaveGenerated = true;
                                    break;
                                }
                            }
                            generateFy = !fyHaveGenerated;
                        }
                        else
                        {
                            generateFy = false;
                        }
                    }
                }
                else
                {
                    generateFy = true;
                }

                if (generateFy)
                {
                    bool fylbSubmitted = false;

                    IList<费用信息> list = (rep as Feng.NH.INHibernateRepository).List<费用信息>(NHibernate.Criterion.DetachedCriteria.For<费用信息>()
                        .Add(NHibernate.Criterion.Expression.Eq("费用项编号", htfyx.费用项编号))
                        .Add(NHibernate.Criterion.Expression.Eq("车辆产值.ID", 产值.ID)));
                    System.Diagnostics.Debug.Assert(list.Count <= 1);
                    if (list.Count == 1)
                    {
                        if (htfyx.收付标志 == 收付标志.收)
                        {
                            fylbSubmitted = list[0].Submitted;
                        }
                        else
                        {
                            fylbSubmitted = list[0].完全标志付;
                        }
                    }

                    // 完全标志还未打
                    if (!fylbSubmitted)
                    {
                        // 不生成理论值为0的
                        if (!金额.HasValue || (金额.HasValue && 金额.Value != 0))
                        {
                            业务费用 item = new 业务费用();
                            item.费用实体 = 产值;
                            item.车辆产值 = 产值;
                            item.费用项编号 = htfyx.费用项编号;
                            
                            item.收付标志 = htfyx.收付标志;
                            item.相关人编号 = 相关人;
                            item.车辆编号 = 产值.车辆编号;
                            item.费用归属 = (htfyx as 车队合同费用项).费用归属;
                            //item.金额 = 金额;
                            if (金额 != null)
                            {
                                ProcessFywithSl(item, 金额.Value);
                            }
                            else
                            {
                                item.金额 = 金额;
                            }
                            if (任务 != null)
                            {
                                item.任务 = 任务;
                            }

                            (new 业务费用Dao()).Save(rep, item);

                            产值.费用.Add(item);
                        }
                    }
                }
            }
        }

        private static void ProcessFywithSl(业务费用理论值 ywfylrz, decimal d)
        {
            IDefinition def = ServiceProvider.GetService<IDefinition>();
            if (ywfylrz.费用项编号 == "203")    // 轮胎补贴
            {
                decimal? dd = Feng.Utils.ConvertHelper.ToDecimal(def.TryGetValue("轮胎补贴率"));
                if (dd.HasValue)
                {
                    ywfylrz.数量 = d;
                    ywfylrz.金额 = d * dd;
                }
                else
                {
                    throw new ArgumentException("数据库中必须配置轮胎补贴率！");
                }
            }
            else if (ywfylrz.费用项编号 == "204" || ywfylrz.费用项编号 == "205") // 油费
            {
                decimal? czyj = Feng.Utils.ConvertHelper.ToDecimal(def.TryGetValue("车主油价"));
                decimal? jsyyj = Feng.Utils.ConvertHelper.ToDecimal(def.TryGetValue("驾驶员油价"));
                decimal? cbyj = Feng.Utils.ConvertHelper.ToDecimal(def.TryGetValue("成本油价"));

                if (ywfylrz.车辆 != null)
                {
                    switch (ywfylrz.车辆.车辆类别)
                    {
                        case 车辆类别.自有车:
                        case 车辆类别.代管车:
                            if (ywfylrz.费用归属 == 费用归属.对外)
                            {
                                if (cbyj.HasValue)
                                {
                                    ywfylrz.数量 = d;
                                    ywfylrz.金额 = d * cbyj;
                                }
                                else
                                {
                                    throw new ArgumentException("数据库中必须配置成本油价！");
                                }
                            }
                            else
                            {
                                if (jsyyj.HasValue)
                                {
                                    ywfylrz.数量 = d;
                                    ywfylrz.金额 = d * jsyyj;
                                }
                                else
                                {
                                    throw new ArgumentException("数据库中必须配置驾驶员油价！");
                                }
                            }
                            break;
                        case 车辆类别.挂靠车:
                            if (ywfylrz.费用归属 == 费用归属.对外)
                            {
                                if (cbyj.HasValue)
                                {
                                    ywfylrz.数量 = d;
                                    ywfylrz.金额 = d * cbyj;
                                }
                                else
                                {
                                    throw new ArgumentException("数据库中必须配置成本油价！");
                                }
                            }
                            else if (ywfylrz.费用归属 == 费用归属.车主)
                            {
                                if (ywfylrz.费用项编号 == "204") //油费
                                {
                                    if (czyj.HasValue)
                                    {
                                        ywfylrz.数量 = d;
                                        ywfylrz.金额 = d * czyj;
                                    }
                                    else
                                    {
                                        throw new ArgumentException("数据库中必须配置车主油价！");
                                    }
                                }
                                else if (ywfylrz.费用项编号 == "205") //定耗油
                                {
                                    if (czyj.HasValue && jsyyj.HasValue)
                                    {
                                        ywfylrz.数量 = d;
                                        ywfylrz.金额 = d * (czyj - jsyyj);
                                    }
                                    else
                                    {
                                        throw new ArgumentException("数据库中必须配置车主油价、驾驶员油价！");
                                    }
                                }
                            }
                            else
                            {
                                throw new ArgumentException("费用归属不规范！");
                            }
                            break;
                        case 车辆类别.外协车:
                            break;
                        default:
                            throw new ArgumentException("车辆类别不规范！");
                    }
                }
            }
            else
            {
                ywfylrz.金额 = d;
            }
        }

        private static void ProcessFywithSl(业务费用 ywfylrz, decimal d)
        {
            IDefinition def = ServiceProvider.GetService<IDefinition>();
            if (ywfylrz.费用项编号 == "203")    // 轮胎补贴
            {
                decimal? dd = Feng.Utils.ConvertHelper.ToDecimal(def.TryGetValue("轮胎补贴率"));
                if (dd.HasValue)
                {
                    ywfylrz.数量 = d;
                    ywfylrz.金额 = d * dd;
                }
                else
                {
                    throw new ArgumentException("数据库中必须配置轮胎补贴率！");
                }
            }
            else if (ywfylrz.费用项编号 == "204" || ywfylrz.费用项编号 == "205") // 油费
            {
                decimal? czyj = Feng.Utils.ConvertHelper.ToDecimal(def.TryGetValue("车主油价"));
                decimal? jsyyj = Feng.Utils.ConvertHelper.ToDecimal(def.TryGetValue("驾驶员油价"));
                decimal? cbyj = Feng.Utils.ConvertHelper.ToDecimal(def.TryGetValue("成本油价"));

                if (ywfylrz.车辆产值.车辆 != null)
                {
                    switch (ywfylrz.车辆产值.车辆.车辆类别)
                    {
                        case 车辆类别.自有车:
                        case 车辆类别.代管车:
                            if (ywfylrz.费用归属 == 费用归属.对外)
                            {
                                if (cbyj.HasValue)
                                {
                                    ywfylrz.数量 = d;
                                    ywfylrz.金额 = d * cbyj;
                                }
                                else
                                {
                                    throw new ArgumentException("数据库中必须配置成本油价！");
                                }
                            }
                            else
                            {
                                if (jsyyj.HasValue)
                                {
                                    ywfylrz.数量 = d;
                                    ywfylrz.金额 = d * jsyyj;
                                }
                                else
                                {
                                    throw new ArgumentException("数据库中必须配置驾驶员油价！");
                                }
                            }
                            break;
                        case 车辆类别.挂靠车:
                            if (ywfylrz.费用归属 == 费用归属.对外)
                            {
                                if (cbyj.HasValue)
                                {
                                    ywfylrz.数量 = d;
                                    ywfylrz.金额 = d * cbyj;
                                }
                                else
                                {
                                    throw new ArgumentException("数据库中必须配置成本油价！");
                                }
                            }
                            else if (ywfylrz.费用归属 == 费用归属.车主)
                            {
                                if (ywfylrz.费用项编号 == "204") //油费
                                {
                                    if (czyj.HasValue)
                                    {
                                        ywfylrz.数量 = d;
                                        ywfylrz.金额 = d * czyj;
                                    }
                                    else
                                    {
                                        throw new ArgumentException("数据库中必须配置车主油价！");
                                    }
                                }
                                else if (ywfylrz.费用项编号 == "205") //定耗油
                                {
                                    if (czyj.HasValue && jsyyj.HasValue)
                                    {
                                        ywfylrz.数量 = d;
                                        ywfylrz.金额 = d * (czyj - jsyyj);
                                    }
                                    else
                                    {
                                        throw new ArgumentException("数据库中必须配置车主油价、驾驶员油价！");
                                    }
                                }
                            }
                            else
                            {
                                throw new ArgumentException("费用归属不规范！");
                            }
                            break;
                        case 车辆类别.外协车:
                            break;
                        default:
                            throw new ArgumentException("车辆类别不规范！");
                    }
                }
            }
            else
            {
                ywfylrz.金额 = d;
            }
        }

        private static decimal? Get理论值(IRepository rep, 车辆产值 产值, 任务 任务, 合同费用项 htfyx)
        {
            decimal? d = null;
            d = (任务 != null) ? Get理论值金额(rep, htfyx, 任务) : Get理论值金额(rep, htfyx, 产值);
            return d;
        }


        private const string s_feeThoeryGenerate = "# -*- coding: UTF-8 -*- " + "\r\n" +
            "import clr" + "\r\n" +
            "import math" + "\r\n" +
            "clr.AddReference('Hd.Model.Base')" + "\r\n" +
            "import Hd" + "\r\n" +
            "if (" + "%IFEXPRESSION%" + "): result = True;" + "\r\n" +
            "else: result = False;";

        private const string s_feeThoeryGenerateResult = "# -*- coding: UTF-8 -*- " + "\r\n" +
            "import clr" + "\r\n" +
            "import math" + "\r\n" +
            "clr.AddReference('Hd.Model.Base')" + "\r\n" +
            "import Hd" + "\r\n" +
            "result = (" + "%IFEXPRESSION%" + ")";

        private const string s_feeThoeryGenerateResult2 = "# -*- coding: UTF-8 -*- " + "\r\n" +
            "import clr" + "\r\n" +
            "import math" + "\r\n" +
            "clr.AddReference('Hd.Model.Base')" + "\r\n" +
            "import Hd" + "\r\n" +
            "%IFEXPRESSION%";

        // 根据相关人不同得到理论值
        // 返回MinValue：没符合的条件，不生成理论值，不生成费用（内部外部都不生成）
        // 返回0：符合条件，生成理论值， 但不生成费用（内部外部都不生成）
        // 返回NULL：符合条件，不生成理论值，但生成空费用记录。在不在生成全部的时候生成看配置，生成单费用项的时候生成
        // 返回具体值：生成记录
        private static decimal? Get理论值金额(IRepository rep, 合同费用项 htfyx, object entity)
        {
            rep.Initialize(htfyx.费用理论值, htfyx);
            foreach (费用理论值信息 i in htfyx.费用理论值)
            {
                string exp = s_feeThoeryGenerate.Replace("%IFEXPRESSION%", i.条件);
                object ret = Script.ExecuteStatement(exp, new Dictionary<string, object> { { "entity", entity } });
                if (ConvertHelper.ToBoolean(ret).Value)
                {
                    if (string.IsNullOrEmpty(i.结果))
                    {
                        return null;
                    }
                    else
                    {
                        if (i.结果.Contains(System.Environment.NewLine))
                        {
                            exp = s_feeThoeryGenerateResult2.Replace("%IFEXPRESSION%", i.结果);
                        }
                        else
                        {
                            exp = s_feeThoeryGenerateResult.Replace("%IFEXPRESSION%", i.结果);
                        }
                        ret = Script.ExecuteStatement(exp, new Dictionary<string, object> { { "entity", entity }, { "rep", rep } });
                        decimal? d = Feng.Utils.ConvertHelper.ToDecimal(ret);
                        if (d.HasValue)
                            return d.Value;
                        else
                            return null;
                    }
                }
            }
            return decimal.MinValue;
        }

        public static string Get相关人(IRepository rep, 车辆产值 产值, 任务 任务, 合同费用项 htfyx)
        {
            
            车队合同费用项 cdhtfyx = htfyx as 车队合同费用项;
            switch (cdhtfyx.费用归属)
            {
                case 费用归属.委托人:
                    return 任务.委托人编号;
                case 费用归属.车主:
                    return 产值.承运人编号;
                case 费用归属.驾驶员:
                    return 产值.驾驶员编号;
                case 费用归属.对外:
                    {
                        object entity;
                        if (任务 != null)
                        {
                            entity = 任务;
                        }
                        else
                        {
                            entity = 产值;
                        }
                        string ret = null;
                        object r = EntityScript.CalculateExpression(cdhtfyx.默认相关人, entity);
                        ret = string.IsNullOrEmpty(cdhtfyx.默认相关人) || r == null ? null : r.ToString().Replace("\"", "");
                        if (string.IsNullOrEmpty(ret))
                        {
                            ret = null;
                        }
                        return ret;
                    }
                default:
                    throw new ArgumentException("Invalid 费用归属!");
            }
        }
    }
}
