using Microsoft.VisualBasic;
using Presentacion.Reportes._2020.Productos.CodigoBarra.Dataset;
using Presentacion.Reportes._2020.Productos.CodigoBarra.Dataset.DataSetCodBarraTableAdapters;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
 

namespace Presentacion.Reportes._2020.Productos.CodigoBarra.forms
{
    public partial class reporteCodbarra : Imprimir
    {
        public int IdPresentacion { get; set; }

        public reporteCodbarra()
        {
            InitializeComponent();
        }

        private void reporteCodbarra_Load(object sender, EventArgs e)
        {
            this.ImprimirReporte();
        }

        void ImprimirReporte()
        {
            try
            {

                var ta = new spCodigoBarraImpresionTableAdapter() {Connection = new SqlConnection(DataSetConexion)};
                var tabla = new DataSetCodBarra.spCodigoBarraImpresionDataTable();
                ta.Fill(tabla, IdPresentacion);
                ParametrosReporte("DataSet1", tabla, "2020\\Productos\\CodigoBarra\\CodigoBarraImpresion.rdlc", reportViewer1);
                this.reportViewer1.RefreshReport();
            }
            catch (Exception e)
            {
                var message = e.InnerException != null ? e.InnerException.ToString() : e.Message;
                MessageBox.Show($@"Ocurrio un error al generar el reporte! {message}");
            }
        }
    }
}
