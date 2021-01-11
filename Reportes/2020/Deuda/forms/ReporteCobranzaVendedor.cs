using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Presentacion.Reportes._2020.Deuda.forms
{
    public partial class ReporteCobranzaVendedor : Imprimir
    {

        public DateTime FechaIni { get; set; }
        public DateTime FechaFin { get; set; }
        public int IdVendedor { get; set; }

        public ReporteCobranzaVendedor()
        {
            InitializeComponent();
        }

        private void ReporteCobranzaVendedor_Load(object sender, EventArgs e)
        {
            Loading(); 
        }

        void Loading()
        {
            try
            {
                LLenar_2();

                datasets.DataSetReporteVendedorTableAdapters.sp_reporte_cobranza_vendedorTableAdapter ta = new datasets.DataSetReporteVendedorTableAdapters.sp_reporte_cobranza_vendedorTableAdapter();
                ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

                datasets.DataSetReporteVendedor.sp_reporte_cobranza_vendedorDataTable tabla = new datasets.DataSetReporteVendedor.sp_reporte_cobranza_vendedorDataTable();
                ta.Fill(tabla, FechaIni, FechaFin, IdVendedor);

                reportViewer1.LocalReport.DataSources.Clear();
                reportViewer1.LocalReport.EnableExternalImages = true;
                ParametrosReporte("DataSet1", (DataTable)tabla, @"2020\Deuda\ReporteVendedor.rdlc", reportViewer1);
                this.reportViewer1.RefreshReport();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

    }
}
