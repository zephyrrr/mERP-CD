using System;
using System.Collections.Generic;
using System.Text;
using Feng;

namespace Cd.Model
{
    public class 车辆产值Dao : Hd.Model.BaseSubmittedDao<车辆产值>
    {
        public override void Submit(Feng.IRepository rep, 车辆产值 entity)
        {
            if (entity.任务.Count == 0)
            {
                throw new InvalidUserOperationException("产值没有包含任务");
            }

            IList<任务> list = entity.任务;
            string strException = null;
            foreach (任务 item in list)
            {
                strException += GetExceptionString(item) + System.Environment.NewLine;
            }
            if (!string.IsNullOrEmpty(strException.Trim()))
            {
                throw new InvalidUserOperationException(strException);
            }
            entity.Submitted = true;
            base.Update(rep, entity);
        }

        public override void Unsubmit(Feng.IRepository rep, 车辆产值 entity)
        {   
            IList<Hd.Model.费用> fy_List = rep.List<Hd.Model.费用>("from 费用 where 费用实体.ID = :费用实体ID", new Dictionary<string, object> { { "费用实体ID", entity.ID } });
            if (fy_List.Count > 0)
            {
                //throw new InvalidUserOperationException("已撤销，但已登记费用，需关注！");
                MessageForm.ShowWarning("已撤销，但已登记费用，需检查！");
            } 
            entity.Submitted = false;
            base.Update(rep, entity);   
        }

        private string GetExceptionString(任务 rw)
        {
            string strException = null;            
            if (rw.箱型 == null)
            {
                strException += "箱型 ";
            }    
            if (rw.指运地 == null)
            {
                strException += "指运地 ";
            }
            //if (rw.还箱地 == null)
            //{
            //    strException += "还箱地 ";
            //}
            switch (rw.任务类别)
            {
                case 任务类别.拆:
                    if (rw.货代自编号 == null && rw.委托人编号 == "900007")
                    {
                        strException = "易可的货代自编号 ";
                    }
                    if (string.IsNullOrEmpty(rw.箱号))
                    {
                        strException += "箱号 ";
                    }
                    if (rw.提箱地 == null)
                    {
                        strException += "提箱地 ";
                    }
                    //if (string.IsNullOrEmpty(rw.船公司编号))
                    //{
                    //    strException += "船公司编号 ";
                    //}
                    if (rw.箱量 == null)
                    {
                        strException += "箱量 ";
                    }
                    if (string.IsNullOrEmpty(rw.提单号))
                    {
                        strException += "提单号 ";
                    }
                    if (!string.IsNullOrEmpty(strException))
                    {
                        strException = "任务类别：拆 (" + strException + ")不能为空";
                    }
                    break;
                case 任务类别.装:
                    if (rw.提箱地 == null)
                    {
                        strException += "提箱地 ";
                    }
                    //if (string.IsNullOrEmpty(rw.船公司编号))
                    //{
                    //    strException += "船公司编号 ";
                    //}
                    //if (string.IsNullOrEmpty(rw.提单号))
                    //{
                    //    strException += "提单号 ";
                    //}
                    if (!string.IsNullOrEmpty(strException))
                    {
                        strException = "任务类别：装 (" + strException + ")不能为空";
                    }
                    
                    break;
                case 任务类别.回:
                    if (!string.IsNullOrEmpty(strException))
                    {
                        strException = "任务类别：回 (" + strException + ")不能为空";
                    }
                    break;
                case 任务类别.驳:
                    if (rw.货代自编号 == null && rw.委托人编号 == "900007")
                    {
                        strException = "易可的货代自编号 ";
                    }
                    if (string.IsNullOrEmpty(rw.箱号))
                    {
                        strException += "箱号 ";
                    }
                    if (rw.提箱地 == null)
                    {
                        strException += "提箱地 ";
                    }
                    //if (string.IsNullOrEmpty(rw.船公司编号))
                    //{
                    //    strException += "船公司编号 ";
                    //}
                    if (rw.箱量 == null)
                    {
                        strException += "箱量 ";
                    }
                    if (string.IsNullOrEmpty(rw.提单号))
                    {
                        strException += "提单号 ";
                    }
                    if (!string.IsNullOrEmpty(strException))
                    {
                        strException = "任务类别：驳 (" + strException + ")不能为空";
                    }
                    break;
                default:
                    break;
            }
            return strException;
        }
    }
}
