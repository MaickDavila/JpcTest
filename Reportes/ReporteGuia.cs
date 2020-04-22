using Microsoft.Reporting.WinForms;
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
    public partial class ReporteGuia : VariablesGlobales
    {
        int IdGuia;
        public ReporteGuia()
        {
            InitializeComponent();
        }
        public ReporteGuia(int id)
        {
            InitializeComponent();
            IdGuia = id;
        }
        void LLenar_2()
        {
            try
            {                
                RutaLogo = RutaFacturador + @"LOGO\logoempresa.jpg";
            }
            catch (Exception ex) { MessageBox.Show(ex.Message, "IMPRESION COMPROBANTE - LLENAR DATOS"); }
        }
        private void ReporteGuia_Load(object sender, EventArgs e)
        {
            try
            {
                LLenar_2();
                DataSetGuiaTableAdapters.spFormatoGuiaTableAdapter ta = new DataSetGuiaTableAdapters.spFormatoGuiaTableAdapter();                
                ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);
                DataSetGuia.spFormatoGuiaDataTable tabla = new DataSetGuia.spFormatoGuiaDataTable();                
                ta.Fill(tabla, IdGuia);
                reportViewer1.LocalReport.DataSources.Clear();
                reportViewer1.LocalReport.EnableExternalImages = true;
                ParametrosReporte("DataSet1", (DataTable)tabla, "Guia.rdlc", reportViewer1);
                this.reportViewer1.RefreshReport();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }            
        }
    }
}
