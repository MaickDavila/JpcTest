using Presentacion.Reportes._2020.Deuda;
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
    public partial class ReporteCobranza : Imprimir
    {
        public DateTime FechaIni { get; set; }
        public DateTime FechaFin { get; set; }


        public ReporteCobranza()
        {
            InitializeComponent();
        }

        private void ReporteCobranza_Load(object sender, EventArgs e)
        {
            Loading();
        }

        void Loading()
        {
            try
            {
                LLenar_2();

                datasets.DataSetReporteCobranzaTableAdapters.sp_reporte_cobranzaTableAdapter ta = new datasets.DataSetReporteCobranzaTableAdapters.sp_reporte_cobranzaTableAdapter();
                ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

               

                datasets.DataSetReporteCobranza.sp_reporte_cobranzaDataTable tabla = new datasets.DataSetReporteCobranza.sp_reporte_cobranzaDataTable();                
                ta.Fill(tabla, FechaIni, FechaFin);

                reportViewer1.LocalReport.DataSources.Clear();
                reportViewer1.LocalReport.EnableExternalImages = true;
                ParametrosReporte("DataSet1", (DataTable)tabla, @"2020\Deuda\ReporteCobranza.rdlc", reportViewer1);
                //
                datasets.DataSetReporteEmitidosTableAdapters.sp_reporte_comprobantes_emitidosTableAdapter ta2 = new datasets.DataSetReporteEmitidosTableAdapters.sp_reporte_comprobantes_emitidosTableAdapter();
                ta2.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);

                datasets.DataSetReporteEmitidos.sp_reporte_comprobantes_emitidosDataTable tabla2 = new datasets.DataSetReporteEmitidos.sp_reporte_comprobantes_emitidosDataTable();
                ta2.Fill(tabla2, FechaIni, FechaFin);
                ParametrosReporte("DataSet2", (DataTable)tabla2, @"2020\Deuda\ReporteCobranza.rdlc", reportViewer1);

                this.reportViewer1.RefreshReport();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
    }
}
