using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Presentacion.Reportes._2020.Reportes.ReporteClienteVenta.form
{
    public partial class formReporteClienteVenta : Imprimir
    {
        public DateTime FechaInit { get; set; }
        public DateTime FechaFin { get; set; }

        public formReporteClienteVenta()
        {
            InitializeComponent();
        }

        private void formReporteClienteVenta_Load(object sender, EventArgs e)
        {
            Imprimir();
        }

        void Imprimir()
        {
            try
            {
                Dataset.DataSetReporteClienteVentaTableAdapters.spReporteClienteVentaTableAdapter ta = new Dataset.DataSetReporteClienteVentaTableAdapters.spReporteClienteVentaTableAdapter();
                ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);
                Dataset.DataSetReporteClienteVenta.spReporteClienteVentaDataTable tabla = new Dataset.DataSetReporteClienteVenta.spReporteClienteVentaDataTable();
                ta.Fill(tabla, FechaInit, FechaFin);
                ParametrosReporte("DataSet1", (DataTable)tabla, "2020\\Reportes\\ReporteClienteVenta\\ReporteClienteVenta.rdlc", reportViewer1);
            }
            catch (Exception e)
            {
                MessageBox.Show("L" + e.Message);
            }
        }

    }
}
