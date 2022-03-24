using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Presentacion.Reportes._2020.Productos.PorPedir.DataSetPorPedirTableAdapters;

namespace Presentacion.Reportes._2020.Productos.PorPedir
{
    public partial class FormPorPedir : Imprimir
    {
        public int IdAlmacen { get; set; }

        public FormPorPedir()
        {
            InitializeComponent();
        }

        private void FormPorPedir_Load(object sender, EventArgs e)
        {
            ImprimirReporte();
        }

        void ImprimirReporte()
        {
            try
            {

                var ta = new SpReporteProductosPorPedirTableAdapter() { Connection = new SqlConnection(DataSetConexion) };
                var tabla = new DataSetPorPedir().SpReporteProductosPorPedir;
                ta.Fill(tabla, IdAlmacen);
                ParametrosReporte("DataSet1", tabla, "2020\\Productos\\PorPedir\\ReportPorPedir.rdlc", reportViewer1);
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
