using Presentacion.Reportes._2020.GastosOperativos.Dataset;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Presentacion.Reportes._2020.GastosOperativos.forms
{
    public partial class gastosOperativos : Imprimir
    {
        int IdGasto = 0;
        public gastosOperativos()
        {
            InitializeComponent();
        }
        public gastosOperativos(int idgasto)
        {
            InitializeComponent();
            IdGasto = idgasto;
        }
        
        private void gastosOperativos_Load(object sender, EventArgs e)
        {
            Imprimir(); 
        }
        void Imprimir()
        {
            try
            {                
                Dataset.DataSetGastosTableAdapters.spBuscarGastosByIdTableAdapter ta2 = new Dataset.DataSetGastosTableAdapters.spBuscarGastosByIdTableAdapter();
                ta2.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);


                DataSetGastos.spBuscarGastosByIdDataTable tabla = new DataSetGastos.spBuscarGastosByIdDataTable();
                ta2.Fill(tabla, IdGasto);

                ParametrosReporte("DataSet1", (DataTable)tabla, "2020\\GastosOperativos\\gastosOperativos.rdlc", reportViewer1);
                 
            }
            catch (Exception e)
            {

                throw e;
            }
        }
    }
}
