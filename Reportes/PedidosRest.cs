using Microsoft.Reporting.WinForms;
using Presentacion.Inicio;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Presentacion.Reportes
{
    public partial class PedidosRest:Form
    {
        public long IdMesa { get; set; }
        public int IdPiso { get; set; }
        public long Id_Venta { get; set; }
        public bool Para_Llevar { get; set; }
        public bool Es_Delivery { get; set; }
        Imprimir _imprimir = new Imprimir();

        public PedidosRest()
        {
            InitializeComponent();
        }


        private void PedidosRest_Load(object sender, EventArgs e)
        {
            if (!Para_Llevar && !Es_Delivery) ImprimirPedidos();
            else ImprimirVentas();
            Close();
        }                
         
        public DataTable ToDataTable<T>(IList<T> data)
        {
            PropertyDescriptorCollection props =
                TypeDescriptor.GetProperties(typeof(T));
            DataTable table = new DataTable();
            for (int i = 0; i < props.Count; i++)
            {
                PropertyDescriptor prop = props[i];
                table.Columns.Add(prop.Name, prop.PropertyType);
            }
            object[] values = new object[props.Count];
            foreach (T item in data)
            {
                for (int i = 0; i < values.Length; i++)
                {
                    values[i] = props[i].GetValue(item);
                }
                table.Rows.Add(values);
            }
            return table;
        }

        void LogicaDistribucion(DataTable FormatoRest)
        {
            List<DataTable> gruposListMaquetas = new List<DataTable>();
            List<RestauranteGrupoImpresoras.Grupo> listImpresoras = new List<RestauranteGrupoImpresoras.Grupo>();

            VariablesGlobales.GrupoImpresorasConfig.Grupos.ForEach(item =>
            {
                DataTable maqueta = new DataTable();
                maqueta = FormatoRest.Clone();
                maqueta.Rows.Clear();

                foreach (DataRow row in FormatoRest.Rows)
                {
                    string nombreGrupo = row["grupo"].ToString();
                    nombreGrupo = nombreGrupo.Trim().ToUpper();

                    if (item.Nombre.Trim().ToUpper().Equals(nombreGrupo)) maqueta.ImportRow(row);
                }

                if (maqueta.Rows.Count > 0)
                {
                    gruposListMaquetas.Add(maqueta);
                    listImpresoras.Add(item);
                }
            });


            if (gruposListMaquetas.Count > 0)
            {
                int count = 0;
                foreach (var item in listImpresoras)
                {
                    item.Impresoras.ForEach(async impresora =>
                    {
                        DataTable data = gruposListMaquetas[count];
                        string reporteName = !Para_Llevar && !Es_Delivery ? impresora.Reporte : Para_Llevar ? impresora.ReporteLlevar : impresora.ReporteDelivery;
                        await ReporteLocal(data, reporteName, impresora.Nombre);
                    });
                    count++;
                }
            }
        }

        void ImprimirVentas()
        {
            DataTable FormatoRest = new DataTable();
            FormatoRest = new VariablesGlobales().N_Venta1.sp_reporte_delivery(Id_Venta);

            bool distribucion = VariablesGlobales.GrupoImpresorasConfig.Grupos.Where(item => item.Enabled == true).Count() > 0;
            if (distribucion) LogicaDistribucion(FormatoRest);

            var configRestaurant = VariablesGlobales.ConfigJson.Tickets.Find(item => item.Tag == "restaurant");
            var configLlevar = configRestaurant.Items.Find(item => item.Name == "llevar");
            var configDelivery = configRestaurant.Items.Find(item => item.Name == "delivery");


            if (Para_Llevar)
            {
                if (configLlevar.State)
                {
                    configLlevar.Printers.ForEach(async item =>
                    {
                        await ReporteLocal(FormatoRest, item.ReportName, item.PrinterName);
                    });
                }
                return;
            }

            else
            {
                if (configDelivery.State)
                {
                    configDelivery.Printers.ForEach(async item =>
                    {
                        await ReporteLocal(FormatoRest, item.ReportName, item.PrinterName);
                    });
                }
                return;
            }
        }

        async void ImprimirPedidos()
        {                    
            try
            {
                DataTable FormatoRest = new DataTable();
                FormatoRest =new VariablesGlobales().N_Venta1.FormatoRest(IdMesa, IdPiso);

                bool distribucion = VariablesGlobales.GrupoImpresorasConfig.Grupos.Where(item => item.Enabled == true).Count() > 0;
                if (distribucion) LogicaDistribucion(FormatoRest);

                var configRestaurant = VariablesGlobales.ConfigJson.Tickets.Find(item => item.Tag == "restaurant");
                var configDefault = configRestaurant.Items.Find(item => item.Name == "default");

                if (configDefault.State)
                {
                    configDefault.Printers.ForEach(async item =>
                    {
                        await ReporteLocal(FormatoRest, item.ReportName, item.PrinterName);
                    });
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            finally
            {
                string result = new VariablesGlobales().N_Venta1.ResetarTemp(int.Parse(IdMesa.ToString()), IdPiso);

                //if (Mensaje == null)
                //    MessageBox.Show("EL TICKET NO SE ELIMINÓ, PORFAVOR CONTACTESE: " + "\n- JORGE PUGA DE LA CRUZ, TELF. 970637964." + "\nMAICK DÁVILA JESÚS, TELF. 970637964", Sistema + "- Puede que se vuelva a imprimir el ticker al cobrar el pedido", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        async Task<bool> ReporteLocal(DataTable data, string nombre_reporte, string nombre_impresora = "Microsoft Print to PDF")
        {
            
            try
            {
                VariablesGlobales.ImpresoranNow = nombre_impresora;
                reportViewer1.LocalReport.DataSources.Clear();

                ReportDataSource dataSource = new ReportDataSource("DataSet1", data);
                VariablesGlobales.RutaQr = "";
                LocalReport relatorio = new LocalReport();
                relatorio.ReportPath = VariablesGlobales.RutaReportes + nombre_reporte;
                relatorio.DataSources.Add(dataSource);
                string PARA = "Para";
                ReportParameter[] parameters = new ReportParameter[11];
                parameters[0] = new ReportParameter(PARA + "QR", @"file:////" + VariablesGlobales.RutaQr, true);
                parameters[1] = new ReportParameter(PARA + "RAZON", VariablesGlobales.Razon, true);
                parameters[2] = new ReportParameter(PARA + "NOMBRECOM", VariablesGlobales.Nombrecom, true);
                parameters[3] = new ReportParameter(PARA + "RUC", new VariablesGlobales().RucEmpresa, true);
                parameters[4] = new ReportParameter(PARA + "TELEFONO", VariablesGlobales.Telefono, true);
                parameters[5] = new ReportParameter(PARA + "DIRECCION", VariablesGlobales.Direccion, true);
                parameters[6] = new ReportParameter(PARA + "WEB", VariablesGlobales.Web, true);
                parameters[7] = new ReportParameter(PARA + "EMAIL", VariablesGlobales.Email, true);
                parameters[8] = new ReportParameter(PARA + "LOGO", @"file:////" + VariablesGlobales.RutaLogo, true);
                parameters[9] = new ReportParameter(PARA + "CIUDAD", VariablesGlobales.Ciudad, true);
                parameters[10] = new ReportParameter(PARA + "DISTRITO", VariablesGlobales.Distrito, true);
                relatorio.EnableExternalImages = true;
                relatorio.SetParameters(parameters);
                _imprimir.Exportar(relatorio);
                _imprimir.ObiarCopias = true;
                _imprimir.Imprimirr(relatorio);

                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }
         
        private void reportViewer1_Load(object sender, EventArgs e)
        {

        }
    }
}
