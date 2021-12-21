using System;
using System.Windows.Forms;

namespace Presentacion.Reportes._2020.Comision.forms
{
    public partial class ReporteComisionForm : Imprimir
    {
        public string Token { get; set; }
        public ReporteComisionForm()
        {
            InitializeComponent();
        }

        private void ReporteComisionForm_Load(object sender, EventArgs e)
        {

            try
            {
                datasets.DataSetComisionTableAdapters.SpGetReporteComisionTableAdapter ta = new datasets.DataSetComisionTableAdapters.SpGetReporteComisionTableAdapter();                 
                ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);
                datasets.DataSetComision.SpGetReporteComisionDataTable tabla = new datasets.DataSetComision.SpGetReporteComisionDataTable();                 
                ta.Fill(tabla, Token);
                ParametrosReporte("DataSet1", tabla, "2020\\Comision\\ReportComision.rdlc", reportViewer1);
            }
            catch (Exception ex)
            {
                MessageBox.Show("ReporteComisionForm_Load: " + ex.Message);
            }             
        }
    }
}
