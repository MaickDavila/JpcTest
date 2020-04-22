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
    public partial class Impresion_Items_Convenio_Factura : VariablesGlobales
    {
        long Id;
        
        public Impresion_Items_Convenio_Factura()
        {
            InitializeComponent();
        }
        public Impresion_Items_Convenio_Factura(long idventa)
        {
            InitializeComponent();
            Id = idventa;
            
        }

        private void Impresion_Items_Convenio_Factura_Load(object sender, EventArgs e)
        {
            try
            {
                LLenar_2();
                DataSetImpresion_Items_Convenio_FacturaTableAdapters.Impresion_Items_Convenio_FacturaTableAdapter ta = new DataSetImpresion_Items_Convenio_FacturaTableAdapters.Impresion_Items_Convenio_FacturaTableAdapter();
                ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);
                DataSetImpresion_Items_Convenio_Factura.Impresion_Items_Convenio_FacturaDataTable tabla = new DataSetImpresion_Items_Convenio_Factura.Impresion_Items_Convenio_FacturaDataTable();
                ta.Fill(tabla, int.Parse(Id.ToString()));                
                reportViewer1.LocalReport.DataSources.Clear();
                reportViewer1.LocalReport.EnableExternalImages = true;
                ParametrosReporte("DataSet1", (DataTable)tabla, "Impresion_Items_Convenio_Factura.rdlc", reportViewer1);
                this.reportViewer1.RefreshReport();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
    }
}
