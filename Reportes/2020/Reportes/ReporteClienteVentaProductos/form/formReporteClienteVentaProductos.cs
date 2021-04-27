using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Presentacion.Reportes._2020.Reportes.ReporteClienteVentaProductos.form
{
    public partial class formReporteClienteVentaProductos : Imprimir
    {
        public DateTime FechaInit { get; set; }
        public DateTime FechaFin { get; set; }


        public formReporteClienteVentaProductos()
        {
            InitializeComponent();
        }

        private void formReporteClienteVentaProductos_Load(object sender, EventArgs e)
        {
            Imprimir();
        }

        void Imprimir()
        {
            try
            {
                DataSet.DataSetReporteClienteVentaProductosTableAdapters.spReporteClienteVentaProductosTableAdapter ta = new DataSet.DataSetReporteClienteVentaProductosTableAdapters.spReporteClienteVentaProductosTableAdapter();
                ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

                DataSet.DataSetReporteClienteVentaProductos.spReporteClienteVentaProductosDataTable tabla = new DataSet.DataSetReporteClienteVentaProductos.spReporteClienteVentaProductosDataTable();
                ta.Fill(tabla, FechaInit, FechaFin);
                ParametrosReporte("DataSet1", (DataTable)tabla, "2020\\Reportes\\ReporteClienteVentaProductos\\ReporteClienteVenta.rdlc", reportViewer1);
            }
            catch (Exception e)
            {
                MessageBox.Show("L" + e.Message);
            }
        }
    }
}
