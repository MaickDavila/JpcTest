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
    public partial class ReporteProforma : VariablesGlobales
    {
        int IdProforma;
        public ReporteProforma()
        {
            InitializeComponent();
        }
        public ReporteProforma(int id)
        {
            InitializeComponent();
            IdProforma = id;
        }
       
        private void ReporteProforma_Load(object sender, EventArgs e)
        {
            try
            {
                LLenar_2();
                DataSetProformaTableAdapters.spFormatoproformaTableAdapter ta = new DataSetProformaTableAdapters.spFormatoproformaTableAdapter();                
                ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);
                DataSetProforma.spFormatoproformaDataTable tabla = new DataSetProforma.spFormatoproformaDataTable();
                ta.Fill(tabla, IdProforma);
                reportViewer1.LocalReport.DataSources.Clear();
                reportViewer1.LocalReport.EnableExternalImages = true;
                ParametrosReporte("DataSet1", (DataTable)tabla, "Proforma.rdlc", reportViewer1);
                this.reportViewer1.RefreshReport();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
    }
}
