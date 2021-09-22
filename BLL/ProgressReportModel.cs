using System.Collections.Generic;

namespace BLL
{
    public class ProgressReportModel
    {
        public int PercentageComplete { get; set; } = 0;
        public List<EmailHelper> SitesDownloaded { get; set; } = new List<EmailHelper>();
    }
}
