using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.IO;
using System.Xml.Serialization;

namespace Cd.Run
{
    static class Program
    {
        /// <summary>
        /// 应用程序的主入口点。
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            if (args.Length == 0)
            {
                //IApplicationContext ctx = ContextRegistry.GetContext();
                //BaseProgram program = (BaseProgram)ctx.GetObject("Program");
                //program.Main(args);

                //using (var rep = ServiceProvider.GetService<IRepositoryFactory>().GenerateRepository())
                //{
                //    rep.List<Hd.Model.费用>("from 费用 where 费用实体.ID = :费用实体ID", new Dictionary<string, object> { { "费用实体ID", Guid.NewGuid() } });
                //}

//                Dictionary<string, string> dict = new Dictionary<string, string>();

//                dict["Cd.Model.Base"] = "Cd.Model.Yw";

//                string[] sqls = new string[] {"update ad_grid_column set type = replace(type, kvp.Key, kvp.Value)",
//"update ad_grid_column set SearchControlInitParam = replace(SearchControlInitParam, kvp.Key, kvp.Value)",
//"update ad_grid_column set CellViewerManagerParam = replace(CellViewerManagerParam, kvp.Key, kvp.Value)",
//"update ad_grid_column set CellEditorManagerParam = replace(CellEditorManagerParam, kvp.Key, kvp.Value)",

//"update ad_window_tab set ControlManagerClassName = replace(ControlManagerClassName, kvp.Key, kvp.Value)",
//"update ad_window_tab set DisplayManagerClassName = replace(DisplayManagerClassName, kvp.Key, kvp.Value)",
//"update ad_window_tab set SearchManagerClassName = replace(SearchManagerClassName, kvp.Key, kvp.Value)",
//"update ad_window_tab set BusinessLayerClassName = replace(BusinessLayerClassName, kvp.Key, kvp.Value)",
//"update ad_window_tab set BusinessLayerClassParams = replace(BusinessLayerClassParams, kvp.Key, kvp.Value)",

//"update ad_grid_related set EntityType = replace(EntityType, kvp.Key, kvp.Value)",

//"update ad_task set SearchManagerName = replace(SearchManagerName, kvp.Key, kvp.Value)" };

//                foreach (KeyValuePair<string, string> kvp in dict)
//                {
//                    foreach (string s in sqls)
//                    {
//                        string sql = s.Replace("kvp.Key", "'" + kvp.Key + "'").Replace("kvp.Value", "'" + kvp.Value + "'");
//                        Feng.Data.DbHelper.Instance.ExecuteNonQuery(sql);
//                    }
//                }
            }
        }
    }
}
