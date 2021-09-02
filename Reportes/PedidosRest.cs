using Microsoft.Reporting.WinForms;
using Presentacion.Inicio;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using RestauranteGrupoImpresoras;

namespace Presentacion.Reportes
{
    public class ModelImpresion
    {
        public Impresoras Impresora { get; set; }
        public DataTable Datos { get; set; }
    }

    public partial class PedidosRest:Form
    {
        public long IdMesa { get; set; }
        public int IdPiso { get; set; }
        public long Id_Venta { get; set; }
        public bool Para_Llevar { get; set; }
        public bool Es_Delivery { get; set; }
        Imprimir _imprimir = new Imprimir();
        private Ticket ConfigRestaurant;


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

        async Task LogicaDistribucion(DataTable FormatoRest)
        {
            ConfigRestaurant = VariablesGlobales.ConfigJson.Tickets.Find(item => item.Tag == "restaurant");
            var configLlevar = ConfigRestaurant.Items.Find(item => item.Name == "llevar");
            var configDelivery = ConfigRestaurant.Items.Find(item => item.Name == "delivery");
            //
            var dataList = new List<ModelImpresion>();
            VariablesGlobales.GrupoImpresorasConfig.Impresoras.ForEach(printerName =>
            {
                var table = new DataTable();
                table.TableName = DateTime.Now.Millisecond.ToString();
                table = FormatoRest.Clone();
                table.Clear();
                var groups = printerName.Grupos;
                foreach (DataRow item in FormatoRest.Rows)
                {
                    var groupItem = item["grupo"].ToString().Trim().ToLower();
                    var exist = groups.FindIndex(group => group.Trim().ToLower() == groupItem);
                    if (exist == -1) continue;
                    table.ImportRow(item);
                }

                if (table.Rows.Count > 0)
                {
                    dataList.Add(new ModelImpresion() {Impresora = printerName, Datos = table});
                }
            });

            dataList.ForEach(async item =>
            {
                var report = Para_Llevar ? item.Impresora.ReporteLlevar : Es_Delivery ? item.Impresora.ReporteDelivery : item.Impresora.Reporte;
                var printerName = item.Impresora.Nombre;
                var data = item.Datos;
                await ReporteLocal(data, report, printerName);
            });
        }

        void ImprimirVentas()
        {
            var FormatoRest = new DataTable();
            FormatoRest = new VariablesGlobales().N_Venta1.sp_reporte_delivery(Id_Venta);
            var distribucion = VariablesGlobales.GrupoImpresorasConfig.Impresoras.FindAll(item => item.Enabled == true)
                .Count > 0;
            if (distribucion) LogicaDistribucion(FormatoRest);

            ConfigRestaurant = VariablesGlobales.ConfigJson.Tickets.Find(item => item.Tag == "restaurant");
            var configLlevar = ConfigRestaurant.Items.Find(item => item.Name == "llevar");
            var configDelivery = ConfigRestaurant.Items.Find(item => item.Name == "delivery");


            if (Para_Llevar)
            {
                if (configLlevar.State)
                {
                    configLlevar.Printers.ForEach(async item =>
                    {
                        await ReporteLocal(FormatoRest, item.ReportName, item.PrinterName);
                    });
                }
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
            }
        }

        async void ImprimirPedidos()
        {                    
            try
            {
                var FormatoRest = new DataTable();
                FormatoRest = new VariablesGlobales().N_Venta1.FormatoRest(IdMesa, IdPiso);

                var distribucion = VariablesGlobales.GrupoImpresorasConfig.Impresoras
                    .FindAll(item => item.Enabled == true).Count > 0;
                if (distribucion) await LogicaDistribucion(FormatoRest);

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
                new VariablesGlobales().N_Venta1.ResetarTemp(int.Parse(IdMesa.ToString()), IdPiso);
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
                parameters[3] = new ReportParameter(PARA + "RUC", VariablesGlobales.RucEmpresa, true);
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
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return false;
            }
        }
         
        private void reportViewer1_Load(object sender, EventArgs e)
        {

        }
    }
}
