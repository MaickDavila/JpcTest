using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Presentacion.Reportes._2020.AlmacenTraslado.dataset;
using Presentacion.Reportes._2020.AlmacenTraslado.dataset.DataSetReporteAlmacenTrasladoTableAdapters;

namespace Presentacion.Reportes._2020.AlmacenTraslado.form
{
    public partial class ReporteAlmacenTraslado : Imprimir
    {
        public  int IdTraslado { get; set; }

        public ReporteAlmacenTraslado()
        {
            InitializeComponent();
        }

        private void ReporteAlmacenTraslado_Load(object sender, EventArgs e)
        {
            Printer();
        }

        void Printer()
        {
            try
            {
                LLenar_2();
                SpGetReporteAlmacenTrasladoTableAdapter ta =
                        new SpGetReporteAlmacenTrasladoTableAdapter();
                ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);
                //
                DataSetReporteAlmacenTraslado.SpGetReporteAlmacenTrasladoDataTable tabla =
                    new DataSetReporteAlmacenTraslado.SpGetReporteAlmacenTrasladoDataTable();
                ta.Fill(tabla, IdTraslado);
                reportViewer1.LocalReport.DataSources.Clear();
                reportViewer1.LocalReport.EnableExternalImages = true;
                ParametrosReporte("DataSet1", (DataTable)tabla, "2020/AlmacenTraslado/ReporteAlmacenTraslado.rdlc", reportViewer1);
                this.reportViewer1.RefreshReport();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
    }
}
