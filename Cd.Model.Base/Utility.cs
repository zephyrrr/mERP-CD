using System;
using System.Collections.Generic;
using System.Text;
using Feng;
using Feng.Utils;
using Hd.Model;

namespace Cd.Model
{
    public class Utility
    {
        public static Dictionary<Tuple<int, 收付标志, string, string>, IList<费用>> GroupFyToPzYsyf(IList<费用> list)
        {
            Dictionary<Tuple<int, 收付标志, string, string>, IList<费用>> dict = CollectionHelper.Group<费用, Tuple<int, 收付标志, string, string>>(list,
                            new CollectionHelper.GetGroupKey<费用, Tuple<int, 收付标志, string, string>>(delegate(费用 i)
                            {
                                if (!i.费用类别编号.HasValue
                                   || string.IsNullOrEmpty(i.费用项编号)
                                   || string.IsNullOrEmpty(i.相关人编号)
                                   || !i.金额.HasValue)
                                {
                                    return null;
                                }
                                return new Tuple<int, 收付标志, string, string>(i.费用类别编号.Value, i.收付标志, i.费用项编号, i.相关人编号);
                            }));
            return dict;
        }

        public static Dictionary<Tuple<int, string>, IList<费用>> GroupFyToDzdYsyf(IList<费用> list)
        {
            Dictionary<Tuple<int, string>, IList<费用>> dict = CollectionHelper.Group<费用, Tuple<int, string>>(list,
                             new CollectionHelper.GetGroupKey<费用, Tuple<int, string>>(delegate(费用 i)
                             {
                                 if (!i.费用类别编号.HasValue
                                    || string.IsNullOrEmpty(i.相关人编号)
                                    || !i.金额.HasValue)
                                 {
                                     return null;
                                 }
                                 return new Tuple<int, string>(i.费用类别编号.Value, i.相关人编号);
                             }));
            return dict;
        }
    }
}
