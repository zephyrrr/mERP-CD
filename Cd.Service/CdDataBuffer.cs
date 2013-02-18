using System;
using System.Collections.Generic;
using System.Text;
using Feng;
using Cd.Model;

namespace Cd.Service
{
    public class CdDataBuffer : Singleton<CdDataBuffer>, IDisposable, IDataBuffer
    {
        public CdDataBuffer()
        {
            ServiceProvider.GetService<IDataBuffers>().AddDataBuffer(this);
        }

        /// <summary>
        /// Dispose
        /// </summary>
        public void Dispose()
        {
            this.Dispose(true);
            System.GC.SuppressFinalize(this);
        }

        /// <summary>
        /// 清理所有正在使用的资源。
        /// </summary>
        /// <param name="disposing">如果应释放托管资源，为 true；否则为 false。</param>
        protected void Dispose(bool disposing)
        {
            if (disposing)
            {
                s_cdhts.Clear();
            }
        }

        public void LoadData()
        {
        }

        public void Reload()
        {
            Clear();
        }
        public void Clear()
        {
            s_cdhts.Clear();
        }
        private Dictionary<string, 车队合同> s_cdhts = new Dictionary<string, 车队合同>();
        public 车队合同 Get车队合同(IRepository rep)
        {
            string key = "车队合同";
            if (!s_cdhts.ContainsKey(key))
            {
                IList<车队合同> list = (rep as Feng.NH.INHibernateRepository).List<车队合同>(NHibernate.Criterion.DetachedCriteria.For<车队合同>()
                            .Add(NHibernate.Criterion.Expression.Le("有效期始", System.DateTime.Today))
                            .Add(NHibernate.Criterion.Expression.Ge("有效期止", System.DateTime.Today))
                            .AddOrder(NHibernate.Criterion.Order.Desc("签约时间"))
                            .SetMaxResults(1));

                if (list.Count > 0)
                {
                    车队合同 fkht = list[0];
                    rep.Initialize(fkht.合同费用项, fkht);
                    s_cdhts[key] = fkht;
                }
                else
                {
                    s_cdhts[key] = null;
                }
            }
            return s_cdhts[key];
        }

        //private Dictionary<string, 受托人合同> s_strhts = new Dictionary<string, 受托人合同>();
        //public 受托人合同 Get受托人合同(IRepository rep, 费用实体类型 费用实体类型, string 受托人编号)
        //{
        //    string key = 费用实体类型.ToString() + "," + 受托人编号;
        //    if (!s_wtrhts.ContainsKey(key))
        //    {
        //        IList<受托人合同> list = rep.Session.CreateCriteria<受托人合同>()
        //                    .Add(NHibernate.Criterion.Expression.Eq("业务类型编号", (int)费用实体类型))
        //                    .Add(NHibernate.Criterion.Expression.Eq("受托人编号", 受托人编号))
        //                    .Add(NHibernate.Criterion.Expression.Le("有效期始", System.DateTime.Today))
        //                    .Add(NHibernate.Criterion.Expression.Ge("有效期止", System.DateTime.Today))
        //                    .AddOrder(NHibernate.Criterion.Order.Desc("签约时间"))
        //                    .SetMaxResults(1)
        //                    .List<受托人合同>();
        //        if (list.Count > 0)
        //        {
        //            受托人合同 strht = list[0];
        //            rep.Initialize(strht.合同费用项, strht);
        //            s_strhts[key] = strht;
        //        }
        //        else
        //        {
        //            s_strhts[key] = null;
        //        }
        //    }
        //    return s_strhts[key];
        //}

        //private Dictionary<string, 委托人合同> s_wtrhts = new Dictionary<string, 委托人合同>();
        //public 委托人合同 Get委托人合同(IRepository rep, 费用实体类型 费用实体类型, string 委托人编号)
        //{
        //    string key = 费用实体类型.ToString() + "," + 委托人编号;
        //    if (!s_wtrhts.ContainsKey(key))
        //    {
        //        IList<委托人合同> list = rep.Session.CreateCriteria<委托人合同>()
        //                    .Add(NHibernate.Criterion.Expression.Eq("业务类型编号", (int)费用实体类型))
        //                    .Add(NHibernate.Criterion.Expression.Eq("委托人编号", 委托人编号))
        //                    .Add(NHibernate.Criterion.Expression.Le("有效期始", System.DateTime.Today))
        //                    .Add(NHibernate.Criterion.Expression.Ge("有效期止", System.DateTime.Today))
        //                    .AddOrder(NHibernate.Criterion.Order.Desc("签约时间"))
        //                    .SetMaxResults(1)
        //                    .List<委托人合同>();
        //        if (list.Count > 0)
        //        {
        //            委托人合同 wtrht = list[0];
        //            rep.Initialize(wtrht.合同费用项, wtrht);
        //            s_wtrhts[key] = wtrht;
        //        }
        //        else
        //        {
        //            s_wtrhts[key] = null;
        //        }
        //    }
        //    return s_wtrhts[key];
        //}
    }
}
